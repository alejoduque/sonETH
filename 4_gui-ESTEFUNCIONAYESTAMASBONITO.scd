// SuperCollider Ethereum Sonification - GUI System (Enhanced)
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-04 02:51:03
// Current User's Login: alejoduque

(
{
    var success = true;
    var statusView, counterView, controlView, controlViewRow2;
    var container;
    var mainTheme, accentColor, backgroundColor, textColor;

    try {
        // Define theme colors
        mainTheme = (
            background: Color.fromHexString("#1E1E2E"),
            foreground: Color.fromHexString("#CDD6F4"),
            accent: Color.fromHexString("#89B4FA"),
            green: Color.fromHexString("#A6E3A1"),
            red: Color.fromHexString("#F38BA8"),
            yellow: Color.fromHexString("#F9E2AF"),
            purple: Color.fromHexString("#CBA6F7")
        );

        backgroundColor = mainTheme.background;
        textColor = mainTheme.foreground;
        accentColor = mainTheme.accent;

        // Create and store window with explicit bounds and custom background color
        ~mainWindow = Window("Ethereum Sonification Control", Rect(100, 100, 640, 500))
            .background_(backgroundColor);

        ~mainWindow.view.layout_(VLayout().margins_(15).spacing_(15));

        // Create header
        ~header = StaticText()
            .string_("Ethereum Sonification")
            .font_(Font("Helvetica", 24, true))
            .align_(\center)
            .stringColor_(mainTheme.purple);

        // Create main container views with appealing spacing
        statusView = View().background_(backgroundColor.blend(Color.black, 0.2))
            .layout_(HLayout().margins_(15).spacing_(20));
        counterView = View().background_(backgroundColor.blend(Color.black, 0.2))
            .layout_(HLayout().margins_(15).spacing_(20));
        controlView = View().background_(backgroundColor.blend(Color.black, 0.1))
            .layout_(HLayout().margins_(15).spacing_(20));
        controlViewRow2 = View().background_(backgroundColor.blend(Color.black, 0.1))
            .layout_(HLayout().margins_(15).spacing_(20));

        // Add rounded corners to all views
        [statusView, counterView, controlView, controlViewRow2].do { |view|
            view.fixedHeight = 120;
            view.decorator = FlowLayout(view.bounds, 10@10, 10@10);
        };

        // Status indicator function with improved aesthetics
        ~makeStatusLight = { |label|
            var container, indicator, labelText;

            container = View().background_(backgroundColor);
            container.layout_(HLayout().margins_(5).spacing_(10));

            indicator = UserView(container)
                .maxHeight_(18)
                .maxWidth_(18)
                .drawFunc_({ |uview|
                    var state = uview.getProperty(\status) ? 0;
                    Pen.fillColor = if(state == 1) { mainTheme.green } { mainTheme.red };
                    Pen.addOval(Rect(1, 1, 16, 16));
                    Pen.fill;

                    // Add glossy effect
                    Pen.fillColor = Color.white.alpha_(0.3);
                    Pen.addOval(Rect(4, 3, 6, 5));
                    Pen.fill;
                });

            labelText = StaticText()
                .string_(label)
                .stringColor_(textColor)
                .font_(Font("Helvetica", 14))
                .minWidth_(80);

            container.layout.add(labelText);
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

        // Counter function with improved appearance
        ~makeCounter = { |label|
            var container, counter, labelText;

            container = View().background_(backgroundColor);
            container.layout_(HLayout().margins_(5).spacing_(10));

            counter = NumberBox()
                .enabled_(false)
                .background_(mainTheme.background.blend(Color.black, 0.3))
                .normalColor_(mainTheme.yellow)
                .typingColor_(mainTheme.yellow)
                .stringColor_(mainTheme.yellow)
                .font_(Font("Helvetica", 14, true))
                .align_(\center)
                .minWidth_(60);

            labelText = StaticText()
                .string_(label)
                .stringColor_(textColor)
                .font_(Font("Helvetica", 14))
                .minWidth_(80);

            container.layout.add(labelText);
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

        // Store specs for control mapping (unchanged)
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

        // Reuse existing knob parameters structure
        ~knobParameters = [
            [\volume, \fmratio, \grainsize, \filterfreq, \pitchoffset],
            [\fmdepth, \graindensity, \decay, \delaymix, \reverbmix]
        ];

        // Enhanced knob function with better aesthetics
        ~makeKnob = { |label, minVal, maxVal, defaultVal=0.5, mapping=\lin|
            var container, knobContainer, spec, knob, displayStr, valueLabel;

            container = View().background_(backgroundColor);
            container.layout_(VLayout().margins_(5).spacing_(5));

            knobContainer = View().background_(backgroundColor);
            knobContainer.layout_(HLayout().margins_(0).spacing_(0));

            spec = ControlSpec(minVal, maxVal, mapping);
            knob = Knob()
                .maxHeight_(80)
                .maxWidth_(80)
                .mode_(\vert)
                .color_([mainTheme.background, accentColor, mainTheme.foreground, mainTheme.foreground.alpha_(0.2)])
                .value_(spec.unmap(defaultVal));

            displayStr = label.asString;
            displayStr = displayStr[0].toUpper ++ displayStr[1..];

            valueLabel = StaticText()
                .string_(displayStr ++ ": " ++ defaultVal.round(0.001))
                .stringColor_(textColor)
                .font_(Font("Helvetica", 12))
                .align_(\center);

            knobContainer.layout.add(knob);
            container.layout.add(knobContainer);
            container.layout.add(valueLabel);

            // Improved knob action with synchronous bus updates (functionality unchanged)
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

            // Store for updates (unchanged)
            ~controlLabels = ~controlLabels ? ();
            ~controlLabels[label.toLower.asSymbol] = valueLabel;
            ~displayLabels = ~displayLabels ? ();
            ~displayLabels[label.toLower.asSymbol] = displayStr;
            ~knobViews = ~knobViews ? ();
            ~knobViews[label.toLower.asSymbol] = knob;

            container;
        };

        // Create first row control knobs
        ~knobs = ();
        ~knobParameters[0].do { |key|
            ~knobs[key] = ~makeKnob.value(
                key.asString,
                ~controlSpecs[key].minval,
                ~controlSpecs[key].maxval,
                ~controlValues[key] ? ~controlSpecs[key].default,
                ~controlSpecs[key].warp
            );
            controlView.layout.add(~knobs[key]);
        };

        // Create second row control knobs
        ~knobParameters[1].do { |key|
            ~knobs[key] = ~makeKnob.value(
                key.asString,
                ~controlSpecs[key].minval,
                ~controlSpecs[key].maxval,
                ~controlValues[key] ? ~controlSpecs[key].default,
                ~controlSpecs[key].warp
            );
            controlViewRow2.layout.add(~knobs[key]);
        };

        // Add all views to main window with proper spacing
        ~mainWindow.layout.add(~header);
        ~mainWindow.layout.add(statusView);
        ~mainWindow.layout.add(counterView);
        ~mainWindow.layout.add(controlView);
        ~mainWindow.layout.add(controlViewRow2);

        // Add footer with version info
        ~footer = StaticText()
            .string_("Ethereum Sonification v1.0")
            .font_(Font("Helvetica", 10))
            .align_(\right)
            .stringColor_(textColor.alpha_(0.7));
        ~mainWindow.layout.add(~footer);

        // Stop existing routine if it exists
        if(~guiRoutine.notNil) { ~guiRoutine.stop };

        // Create update routine with improved refresh rate (unchanged functionality)
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

        // Set window cleanup (unchanged)
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