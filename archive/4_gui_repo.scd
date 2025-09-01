// SuperCollider Ethereum Sonification - GUI System
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-04 02:51:03
// Current User's Login: alejoduque

(
{
    var success = true;
    var statusView, counterView, controlView;
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

        // Add status lights
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

        // Add counters
        ~counters.keysValuesDo({ |key, counter|
            counterView.layout.add(counter.parent);
        });

        // Store specs for control mapping
        ~controlSpecs = (
            volume: ControlSpec(0, 1, \lin),
            fmratio: ControlSpec(0.5, 4, \exp),
            grainsize: ControlSpec(0.01, 0.5, \exp),
            filterfreq: ControlSpec(200, 5000, \exp),
            pitchoffset: ControlSpec(-12, 12, \lin),
            fmdepth: ControlSpec(0, 1, \lin),
            graindensity: ControlSpec(5, 50, \exp),
            decay: ControlSpec(0.5, 3, \lin),
            delaymix: ControlSpec(0, 1, \lin),
            reverbmix: ControlSpec(0, 1, \lin)
        );

        // Improved knob function with value display
        ~makeKnob = { |label, minVal, maxVal, defaultVal=0.5, mapping=\lin|
            var container = View().layout_(VLayout());
            var knobContainer = View().layout_(HLayout());
            var spec = ControlSpec(minVal, maxVal, mapping);
            var knob = Knob()
                .maxHeight_(80)
                .maxWidth_(80)
                .mode_(\vert)
                .value_(spec.unmap(defaultVal));
            var displayStr = label.asString;
            var valueLabel;
            
            displayStr = displayStr[0].toUpper ++ displayStr[1..];
            valueLabel = StaticText()
                .string_(displayStr ++ ": " ++ defaultVal.round(0.001))
                .align_(\center);
            
            knobContainer.layout.add(knob);
            container.layout.add(knobContainer);
            container.layout.add(valueLabel);
            
            // Improved knob action with synchronous bus updates
            knob.action = { |k|
                var mappedVal = spec.map(k.value);
                try {
                    ~controlBuses[label.toLower.asSymbol].setSynchronous(mappedVal);
                    ~controlValues[label.toLower.asSymbol] = mappedVal;
                    valueLabel.string = displayStr ++ ": " ++ mappedVal.round(0.001);
                    
                    // Update active synths immediately
                    if(~currentSynths.notNil) {
                        ~currentSynths.do { |synth|
                            if(synth.notNil && synth.isPlaying) {
                                synth.set(
                                    (label.toLower ++ "Bus").asSymbol,
                                    ~controlBuses[label.toLower.asSymbol].index
                                );
                            };
                        };
                    };
                };
            };
            
            // Store for updates
            ~controlLabels = ~controlLabels ? ();
            ~controlLabels[label.toLower.asSymbol] = valueLabel;
            ~displayLabels = ~displayLabels ? ();
            ~displayLabels[label.toLower.asSymbol] = displayStr;
            ~knobViews = ~knobViews ? ();
            ~knobViews[label.toLower.asSymbol] = knob;
            
            container;
        };

        // Create control knobs with proper ranges
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

        // Create update routine with improved refresh rate
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

                    // Update knobs from control buses
                    if(~controlBuses.notNil and: { ~knobViews.notNil }) {
                        ~controlBuses.keysValuesDo { |key, bus|
                            if(~knobViews[key].notNil) {
                                var val = bus.getSynchronous;
                                var spec = ~controlSpecs[key];
                                if(spec.notNil) {
                                    ~knobViews[key].value = spec.unmap(val);
                                    if(~controlLabels[key].notNil) {
                                        ~controlLabels[key].string = 
                                            ~displayLabels[key] ++ ": " ++ val.round(0.001);
                                    };
                                };
                            };
                        };
                    };

                    // Refresh all status lights
                    ~statusLights.do(_.refresh);
                }.defer;
                0.02.wait;  // 50Hz refresh rate
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