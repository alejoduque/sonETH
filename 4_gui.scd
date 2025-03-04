// SuperCollider Ethereum Sonification - GUI System
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-03 19:33:44
// Current User's Login: alejoduque
// Author: Alejandro Duque Jaramillo

(
{
    var success = true;
    var statusView, counterView, controlView;  // Declare all vars at the start
    var container;

    try {
        // Create and store window with explicit bounds
        ~mainWindow = Window("Ethereum Sonification Control", Rect(100, 100, 600, 400))
            .layout_(VLayout());

        // Create main container views
        statusView = View().layout_(HLayout().margins_(20));
        counterView = View().layout_(HLayout().margins_(20));
        controlView = View().layout_(HLayout().margins_(20));

        // Status indicator function
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

        // Create status indicators
        ~statusLights = (
            server: ~makeStatusLight.value("Server:"),
            beat: ~makeStatusLight.value("Beat Engine:"),
            osc: ~makeStatusLight.value("OSC:"),
            midi: ~makeStatusLight.value("MIDI:")
        );

        // Add status lights to status view
        ~statusLights.keysValuesDo({ |key, light|
            statusView.layout.add(light.parent);
        });

        // Counter function
        ~makeCounter = { |label|
            var container = View().layout_(HLayout());
            var counter = NumberBox()
                .enabled_(false)
                .string_("0")
                .minWidth_(50);
            
            container.layout.add(StaticText().string_(label).minWidth_(80));
            container.layout.add(counter);
            counter;
        };

        // Create counters
        ~counters = (
            notes: ~makeCounter.value("Notes:"),
            beats: ~makeCounter.value("Beats:"),
            trans: ~makeCounter.value("Trans:"),
            midi: ~makeCounter.value("MIDI:")
        );

        // Add counters to counter view
        ~counters.keysValuesDo({ |key, counter|
            counterView.layout.add(counter.parent);
        });

        // Store specs for MIDI-to-knob conversion
        ~controlSpecs = (
            volume: ControlSpec(0, 1, \lin),
            fmratio: ControlSpec(0.5, 4, \exp),
            grainsize: ControlSpec(0.01, 0.5, \exp),
            filterfreq: ControlSpec(200, 5000, \exp)
        );

        // Control knob function with value display
        ~makeKnob = { |label, minVal, maxVal, defaultVal=0.5, mapping=\lin|
            var container = View().layout_(VLayout());
            var knobContainer = View().layout_(HLayout());
            var spec = ControlSpec(minVal, maxVal, mapping);
            var knob = Knob()
                .maxHeight_(80)
                .maxWidth_(80);
            var displayStr = label.asString;
            var valueLabel;
            
            displayStr = displayStr[0].toUpper ++ displayStr[1..];
            valueLabel = StaticText()
                .string_(displayStr ++ ": " ++ defaultVal.round(0.001))
                .align_(\center);
            
            knobContainer.layout.add(knob);
            container.layout.add(knobContainer);
            container.layout.add(valueLabel);
            
            knob.action = { |k|
                var mappedVal = spec.map(k.value);
                try {
                    ~controlBuses[label.toLower.asSymbol].set(mappedVal);
                    ~controlValues[label.toLower.asSymbol] = mappedVal;
                    valueLabel.string = displayStr ++ ": " ++ mappedVal.round(0.001);
                };
            };
            
            // Store for updates
            ~controlLabels = ~controlLabels ? ();
            ~controlLabels[label.toLower.asSymbol] = valueLabel;
            ~displayLabels = ~displayLabels ? ();
            ~displayLabels[label.toLower.asSymbol] = displayStr;
            ~knobViews = ~knobViews ? ();
            ~knobViews[label.toLower.asSymbol] = knob;
            ~controlSpecs[label.toLower.asSymbol] = spec;
            
            knob.value = spec.unmap(defaultVal);
            container;
        };

        // Create control knobs
        ~knobs = (
            volume: ~makeKnob.value("Volume", 0, 1, ~controlValues.volume ? 0.3),
            fmratio: ~makeKnob.value("FmRatio", 0.5, 4, ~controlValues.fmratio ? 1.0, \exp),
            grainsize: ~makeKnob.value("GrainSize", 0.01, 0.5, ~controlValues.grainsize ? 0.1, \exp),
            filterfreq: ~makeKnob.value("FilterFreq", 200, 5000, ~controlValues.filterfreq ? 1000, \exp)
        );

        // Add knobs to control view
        ~knobs.keysValuesDo({ |key, knob|
            controlView.layout.add(knob);
        });

        // Add all views to main window
        ~mainWindow.layout.add(statusView);
        ~mainWindow.layout.add(counterView);
        ~mainWindow.layout.add(controlView);

        // Stop existing routine if it exists
        if(~guiRoutine.notNil) { ~guiRoutine.stop };

        // Create update routine
        ~guiRoutine = Routine({
            loop {
                {
                    // Update status indicators
                    ~statusLights.server.setProperty(\status, Server.default.serverRunning.binaryValue);
                    ~statusLights.beat.setProperty(\status, (~beatEngine.notNil and: { ~beatEngine.running }).binaryValue);
                    ~statusLights.osc.setProperty(\status, ~handleTransaction.notNil.binaryValue);
                    ~statusLights.midi.setProperty(\status, MIDIClient.sources.notEmpty.binaryValue);

                    // Update counters
                    ~counters.notes.string = (~noteCounter ? 0).asString;
                    ~counters.beats.string = (~beatCounter ? 0).asString;
                    ~counters.trans.string = (~transactionCounter ? 0).asString;
                    ~counters.midi.string = (~midiCounter ? 0).asString;

                    // Update control values from MIDI
                    if(~controlValues.notNil) {
                        ~controlLabels.keysValuesDo { |key, label|
                            if(~controlValues[key].notNil) {
                                var val = ~controlValues[key];
                                var spec = ~controlSpecs[key];
                                if(spec.notNil) {
                                    // Update knob position
                                    ~knobViews[key].value = spec.unmap(val);
                                };
                                // Update label
                                label.string = ~displayLabels[key] ++ ": " ++ val.round(0.001);
                            };
                        };
                    };

                    // Refresh all status lights
                    ~statusLights.do(_.refresh);
                }.defer;
                0.1.wait;
            }
        }).play(AppClock);

        // Set window cleanup
        ~mainWindow.onClose = {
            ~guiRoutine.stop;
            ~guiRoutine = nil;
            ~mainWindow = nil;
            ~statusLights = nil;
            ~counters = nil;
            ~knobs = nil;
            ~controlLabels = nil;
            ~displayLabels = nil;
            ~knobViews = nil;
            ~controlSpecs = nil;
        };

        ~mainWindow.front;
        "GUI System loaded successfully.".postln;
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