// SuperCollider Ethereum Sonification - GUI System
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-06 17:14:08
// Current User's Login: alejoduque

(
{
    var success = true;
    var statusView, counterView, controlView;
    var container;

    try {
        // Create window with original layout
        ~mainWindow = Window("Ethereum Sonification Control", Rect(100, 100, 600, 400))
            .layout_(VLayout());

        // Create container views with original margins
        statusView = View().layout_(HLayout().margins_(20));
        counterView = View().layout_(HLayout().margins_(20));
        controlView = View().layout_(HLayout().margins_(20));

        // Status light function
        ~makeStatusLight = { |label|
            var container = View().layout_(HLayout());
            var indicator = UserView(container)
                .maxHeight_(20)
                .maxWidth_(20)
                .drawFunc_({ |uview|
                    var state = uview.getProperty(\status) ? 0;
                    Pen.fillColor = if(state == 1) { Color.green } { Color.red };
                    Pen.addOval(Rect(0, 0, 20, 20));
                    Pen.fill;
                });

            container.layout.add(StaticText().string_(label).minWidth_(80));
            container.layout.add(indicator);
            indicator.setProperty(\status, 0);
            indicator;
        };

        // Counter function
        ~makeCounter = { |label|
            var container = View().layout_(HLayout());
            var counter = NumberBox()
                .enabled_(false)
                .string_("0")
                .minWidth_(50)
                .stringColor_(Color.black)
                .background_(Color.white);

            container.layout.add(StaticText().string_(label).minWidth_(80).stringColor_(Color.black));
            container.layout.add(counter);
            counter;
        };

        // Create status indicators
        ~statusLights = (
            server: ~makeStatusLight.value("Server:"),
            beat: ~makeStatusLight.value("Beat Engine:"),
            osc: ~makeStatusLight.value("OSC:"),
            midi: ~makeStatusLight.value("MIDI:")
        );

        // Add status lights
        ~statusLights.keysValuesDo({ |key, light|
            statusView.layout.add(light.parent);
        });

        // Create counters
        ~counters = (
            notes: ~makeCounter.value("Notes:"),
            beats: ~makeCounter.value("Beats:"),
            trans: ~makeCounter.value("Trans:"),
            midi: ~makeCounter.value("MIDI:")
        );

        // Add counters
        ~counters.keysValuesDo({ |key, counter|
            counterView.layout.add(counter.parent);
        });

        // Store specs for control mapping
        ~controlSpecs = (
            volume: ControlSpec(0, 1, \lin),
            fmratio: ControlSpec(0.5, 4, \exp),
            fmdepth: ControlSpec(0, 1, \lin),
            filterfreq: ControlSpec(200, 5000, \exp)
        );

        // Knob function
        ~makeKnob = { |label, minVal, maxVal, defaultVal=0.5, mapping=\lin|
            var container = View().layout_(VLayout());
            var knob = Knob()
                .maxHeight_(80)
                .maxWidth_(80)
                .mode_(\vert)
                .color_([Color.grey, Color.white, Color.green, Color.green])
                .background_(Color.grey)
                .value_(defaultVal);
            var valueLabel = StaticText()
                .string_(label ++ ": " ++ defaultVal.round(0.001))
                .stringColor_(Color.black)
                .align_(\center);

            container.layout.add(knob);
            container.layout.add(valueLabel);

            knob.action = { |k|
                var mappedVal = ControlSpec(minVal, maxVal, mapping).map(k.value);
                try {
                    ~controlBuses[label.toLower.asSymbol].setSynchronous(mappedVal);
                    ~controlValues[label.toLower.asSymbol] = mappedVal;
                    valueLabel.string = label ++ ": " ++ mappedVal.round(0.001);
                };
            };

            ~controlLabels = ~controlLabels ? ();
            ~controlLabels[label.toLower.asSymbol] = valueLabel;
            ~knobViews = ~knobViews ? ();
            ~knobViews[label.toLower.asSymbol] = knob;

            container;
        };

        // Create knobs
        ~knobs = (
            volume: ~makeKnob.value("Volume (CC 0)", 0, 1, ~controlValues.volume ? 0.3),
            fmratio: ~makeKnob.value("FM Ratio (CC 1)", 0.5, 4, ~controlValues.fmratio ? 1.0, \exp),
            fmdepth: ~makeKnob.value("FM Depth (CC 32)", 0, 1, ~controlValues.fmdepth ? 0.2),
            filterfreq: ~makeKnob.value("Filter (CC 3)", 200, 5000, ~controlValues.filterfreq ? 1000, \exp)
        );

        // Add knobs to control view
        ~knobs.keysValuesDo({ |key, knob|
            controlView.layout.add(knob);
        });

        // Add all views to main window
        ~mainWindow.layout.add(statusView);
        ~mainWindow.layout.add(counterView);
        ~mainWindow.layout.add(controlView);

        // GUI update routine
        if(~guiRoutine.notNil) { ~guiRoutine.stop };

        ~guiRoutine = Routine({
            loop {
                {
                    // Update status indicators
                    ~statusLights.server.setProperty(\status, Server.default.serverRunning.binaryValue);
                    ~statusLights.beat.setProperty(\status, (~beatEngine.notNil and: { ~beatParams.isRunning }).binaryValue);
                    ~statusLights.osc.setProperty(\status, ~handleTransaction.notNil.binaryValue);
                    ~statusLights.midi.setProperty(\status, MIDIClient.sources.notEmpty.binaryValue);

                    // Update counters
                    ~counters.notes.string = (~noteCounter ? 0).asString;
                    ~counters.beats.string = (~beatCounter ? 0).asString;
                    ~counters.trans.string = (~transactionCounter ? 0).asString;
                    ~counters.midi.string = (~midiCounter ? 0).asString;

                    // Update knobs from control values
                    ~controlValues.keysValuesDo { |key, val|
                        if(~knobViews[key].notNil) {
                            var spec = ~controlSpecs[key];
                            if(spec.notNil) {
                                ~knobViews[key].value = val;
                                if(~controlLabels[key].notNil) {
                                    ~controlLabels[key].string =
                                        key.asString.capitalize ++ ": " ++ val.round(0.001);
                                };
                            };
                        };
                    };

                    // Refresh status lights
                    ~statusLights.do(_.refresh);
                }.defer;
                0.02.wait;
            }
        }).play(AppClock);

        // Window cleanup
        ~mainWindow.onClose = {
            ~guiRoutine.stop;
            ~guiRoutine = nil;
            ~mainWindow = nil;
            ~statusLights = nil;
            ~counters = nil;
            ~knobs = nil;
            ~controlLabels = nil;
            ~knobViews = nil;
        };

        ~mainWindow.front;
        "GUI System loaded - MIDI-to-knob sync enabled".postln;
        success;
    } {
        |error|
        "GUI initialization failed: %".format(error.errorString).error;
        if(~guiRoutine.notNil) { ~guiRoutine.stop };
        if(~mainWindow.notNil) { ~mainWindow.close };
        false;
    }
}.value;
)