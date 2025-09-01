(
// SuperCollider Ethereum Sonification - Simplified MIDI Controller GUI
// Fusion of oscilloscope-inspired visual style with simplified implementation


// abre pero no suena!



// GUI color scheme - oscilloscope inspired
~guiColors = (
    background: Color.black,
    knobFill: Color(0.2, 0.4, 0.2),
    knobStroke: Color.green,
    text: Color.green,
    grid: Color(0, 0.3, 0, 0.4),
    highlight: Color(0.3, 1, 0.3),
    scopeLine: Color(0, 0.8, 0),
    scopeBackground: Color(0, 0.1, 0)
);

// GUI dimensions and layout
~guiDimensions = (
    margins: 20,
    knobSize: 70,
    scopeHeight: 150
);

// Create display labels lookup table
~displayLabels = (
    volume: "Volume",
    fmratio: "FM Ratio",
    grainsize: "Grain Size",
    filterfreq: "Filter Freq",
    pitchoffset: "Pitch Offset",
    fmdepth: "FM Depth",
    graindensity: "Grain Density",
    decay: "Decay Time",
    delaymix: "Delay Mix",
    reverbmix: "Reverb Mix"
);

// Initialize containers for views
~knobViews = ();
~valueLabels = ();

// Create main window with explicit position
~window = Window("Ethereum Sonification Controller", Rect(100, 100, 800, 600), border: true)
    .background_(~guiColors.background)
    .onClose_({
        "GUI closed".postln;
        if(~animationRoutine.notNil) { ~animationRoutine.stop };
    });

// Create main vertical layout for window
~mainLayout = VLayout();
~window.layout = ~mainLayout;

// Add title at the top
~mainLayout.add(
    StaticText()
        .string_("ETHEREUM SONIFICATION CONTROLLER")
        .font_(Font("Monaco", 18, true))
        .stringColor_(~guiColors.highlight)
        .align_(\center)
);

// Create scope view
~scopeView = UserView()
    .background_(~guiColors.scopeBackground)
    .minHeight_(~guiDimensions.scopeHeight)
    .drawFunc_({|view|
        var width = view.bounds.width;
        var height = view.bounds.height;

        // Draw grid
        Pen.color = ~guiColors.grid;
        // Vertical lines
        (0..10).do { |i|
            var x = (i/10) * width;
            Pen.line(x@0, x@height);
        };
        // Horizontal lines
        (0..4).do { |i|
            var y = (i/4) * height;
            Pen.line(0@y, width@y);
        };
        Pen.stroke;

        // Draw waveform if data exists
        if(~scopeData.notNil) {
            Pen.color = ~guiColors.scopeLine;
            Pen.width = 2;
            Pen.moveTo(0@(height/2));
            ~scopeData.do { |val, i|
                var x = (i / (~scopeData.size-1)) * width;
                var y = height * (1 - ((val + 1) / 2));
                Pen.lineTo(x@y);
            };
            Pen.stroke;
        };
    });

// Add scope view with label
~mainLayout.add(
    VLayout(
        StaticText()
            .string_("Signal Monitor")
            .font_(Font("Monaco", 14))
            .stringColor_(~guiColors.text)
            .align_(\left),
        ~scopeView
    ).margins_(~guiDimensions.margins)
);

// Status indicator
~mainLayout.add(
    HLayout(
        StaticText()
            .string_("MIDI Status:")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 12)),
        ~midiStatusLabel = StaticText()
            .string_("Initialized")
            .stringColor_(~guiColors.highlight)
            .font_(Font("Monaco", 12)),
        nil  // spacer
    ).margins_(~guiDimensions.margins)
);

// Function to create knobs
~createKnobs = {
    ~knobParameters.do {|row, rowIndex|
        row.do {|param, colIndex|
            // Declare ALL variables at the beginning of this block
            var name, spec, initialValue, container, knob, nameLabel, valueLabel;

            name = param;
            spec = ~controlSpecs[name];
            initialValue = spec.unmap(~controlValues[name] ? spec.default ? spec.minval);

            // Knob container
            container = View()
                .background_(~guiColors.background);

            // Create knob
            knob = Knob(container, Rect(
                (~guiDimensions.knobSize/2),
                0,
                ~guiDimensions.knobSize,
                ~guiDimensions.knobSize
            ))
            .value_(initialValue)
            .color_(~guiColors.knobFill, ~guiColors.background, ~guiColors.knobStroke, ~guiColors.highlight)
            .action_({|knobView|
                var mappedVal = spec.map(knobView.value);

                // Update control values
                ~controlValues[name] = mappedVal;

                // Update control buses if they exist
                if(~controlBuses[name].notNil) {
                    ~controlBuses[name].setSynchronous(mappedVal);
                };

                // Update synths if they exist
                if(~currentSynths.notNil) {
                    ~currentSynths.do { |synth|
                        if(synth.notNil and: { synth.isPlaying }) {
                            synth.set(
                                name, mappedVal,
                                (name ++ "Bus").asSymbol, ~controlBuses[name].index
                            );
                        };
                    };
                };

                // Update value label
                ~valueLabels[name].string = mappedVal.round(0.001).asString;
            });

            // Store reference
            ~knobViews[name] = knob;

            // Create labels (now using the variables declared at the beginning)
            nameLabel = StaticText(container, Rect(0, ~guiDimensions.knobSize + 5, ~guiDimensions.knobSize*2, 20))
                .string_(~displayLabels[name])
                .stringColor_(~guiColors.text)
                .font_(Font("Monaco", 12))
                .align_(\center);

            valueLabel = StaticText(container, Rect(0, ~guiDimensions.knobSize + 25, ~guiDimensions.knobSize*2, 20))
                .string_(~controlValues[name].round(0.001).asString)
                .stringColor_(~guiColors.highlight)
                .font_(Font("Monaco", 12))
                .align_(\center);

            ~valueLabels[name] = valueLabel;

            // Add to grid
            ~knobGrid.add(container, rowIndex, colIndex);
        };
    };
};

// Create date/time display
~mainLayout.add(
    HLayout(
        StaticText()
            .string_("Current Date/Time:")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 10)),
        ~dateTimeLabel = StaticText()
            .string_(Date.getDate.asString)
            .stringColor_(~guiColors.highlight)
            .font_(Font("Monaco", 10)),
        nil  // spacer
    ).margins_(~guiDimensions.margins)
);

// Initialize simple wave data for scope
~scopeData = Array.fill(200, {|i| sin(i * 0.1) * 0.5 });

// Setup animation for scope and date/time updates
~setupAnimation = {
    if(~animationRoutine.notNil) { ~animationRoutine.stop };

    ~animationRoutine = Routine {
        var t = 0;

        loop {
            // Generate waveform
            ~scopeData = Array.fill(200, {|i|
                sin(i * 0.1 + t) * 0.5 * sin(t * 0.2) +
                sin(i * 0.05 + t * 0.5) * 0.3
            });

            {
                // Update scope view
                ~scopeView.refresh;

                // Update date time
                if(~dateTimeLabel.notNil) {
                    ~dateTimeLabel.string = Date.getDate.asString;
                };

                // Update MIDI status indicator
                try {
                    // Simple check that's wrapped in error handling
                    if(~midiCounter.notNil && ~midiCounter > 0) {
                        ~midiStatusLabel.string = "Receiving";
                        ~midiStatusLabel.stringColor = Color.yellow;
                        ~lastMidiCounter = ~midiCounter;
                    } {
                        ~midiStatusLabel.string = "Initialized";
                        ~midiStatusLabel.stringColor = ~guiColors.highlight;
                    };
                } { |err|
                    // Silent error handling - prevents GUI from crashing
                    // Optionally for debugging:
                    // "MIDI indicator error: ".post; err.errorString.postln;
                };
            }.defer;

            t = t + 0.1;
            0.05.wait;
        };
    };

    AppClock.play(~animationRoutine);
};

// Setup function to periodically check control values and update knobs
~setupKnobUpdates = {
    Routine {
        loop {
            {
                // Update all knobs from control values
                ~knobViews.keysValuesDo {|key, knob|
                    var spec = ~controlSpecs[key];
                    var unmappedVal = spec.unmap(~controlValues[key]);
                    knob.value = unmappedVal;

                    // Update value labels
                    if(~valueLabels[key].notNil) {
                        ~valueLabels[key].string = ~controlValues[key].round(0.001).asString;
                    };
                };
            }.defer;

            0.1.wait;  // Update at 10Hz
        };
    }.play(AppClock);
};

// Initialize values if not already set
if(~controlValues.isNil) {
    ~controlValues = ();
    ~controlSpecs.keysValuesDo {|key, spec|
        ~controlValues[key] = spec.default;
    };
};

// Initialize everything
"Initializing Ethereum Sonification GUI...".postln;
~createKnobs.value;
~setupAnimation.value;
~setupKnobUpdates.value;

// Show the window
~window.front;
"Ethereum Sonification GUI started".postln;

// Return window for chaining
~window;
)