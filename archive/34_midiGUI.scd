// SuperCollider Ethereum Sonification - MIDI Controller GUI
// Oscilloscope-inspired visual style
// Part 1: Window setup and basic framework

(
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
    window: (800@600),
    margins: 20,
    knobSize: 80,
    knobSpacing: 100,
    labelHeight: 20,
    scopeHeight: 150
);

// Create main window
~window = Window("Ethereum Sonification Controller", ~guiDimensions.window, border: true)
    .background_(~guiColors.background)
    .onClose_({
        // Stop any monitoring or animation
        if(~scopeRoutine.notNil) { ~scopeRoutine.stop };
        if(~animationRoutine.notNil) { ~animationRoutine.stop };
        if(~scopeBuffer.notNil) { ~scopeBuffer.free };
        if(~scopeBus.notNil) { ~scopeBus.free };
        "GUI closed".postln;
    });

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
~controlLabels = ();
~valueLabels = ();
~scopeViews = ();

// Create main layout
~mainLayout = VLayout(
    // Top section for title and status
    HLayout(
        StaticText()
            .string_("ETHEREUM SONIFICATION CONTROLLER")
            .font_(Font("Monaco", 18, true))
            .stringColor_(~guiColors.highlight)
            .align_(\center),
    ).margins_(~guiDimensions.margins),

    // Scope view
    View().layout_(
        VLayout(
            StaticText()
                .string_("Signal Monitor")
                .font_(Font("Monaco", 14))
                .stringColor_(~guiColors.text)
                .align_(\left),
            ~scopeViews.main = UserView()
                .background_(~guiColors.scopeBackground)
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

                    // Placeholder for actual signal
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
                })
                .minHeight_(~guiDimensions.scopeHeight)
        )
    ).margins_(~guiDimensions.margins),

    // Initialize knob layout - will be populated in next segment
    ~knobLayout = GridLayout()
);

// Apply layout to window
~window.layout = ~mainLayout;

// Create bus for monitoring audio
~scopeBus = Bus.audio(s, 1);
~scopeBuffer = Buffer.alloc(s, 1024);
~scopeData = Array.fill(1024, {0.0});

// Set up audio monitoring
s.waitForBoot({
    ~monitor = SynthDef(\scopeMonitor, {
        var in = In.ar(~scopeBus.index);
        ScopeOut2.ar(in, ~scopeBuffer.bufnum);
        Out.ar(0, in * 0.0); // Pass through with zero gain
    }).play;
});

// Populate knob layouts (next segment)
//)
// SuperCollider Ethereum Sonification - MIDI Controller GUI
// Oscilloscope-inspired visual style
// Part 2: Custom knob implementation and grid layout

//(
// Custom knob implementation with oscilloscope-style appearance
~createOscilloscopeKnob = {|parent, spec, initVal, label, action|
    var knob, size = ~guiDimensions.knobSize;
    var knobVal = initVal ? 0;
    var active = false;
    var lastMouseY, range = 200;

    knob = UserView(parent, size@size)
    .canFocus_(true)
    .background_(~guiColors.background)
    .focusGainedAction_({|v| v.refresh})
    .focusLostAction_({|v| active = false; v.refresh})
    .mouseDownAction_({|v, x, y|
        active = true;
        lastMouseY = y;
        v.focus(true);
    })
    .mouseMoveAction_({|v, x, y|
        if(active) {
            var delta = (lastMouseY - y) / range;
            knobVal = (knobVal + delta).clip(0, 1);
            lastMouseY = y;
            action.value(spec.map(knobVal));
            v.refresh;
        }
    })
    .mouseUpAction_({|v, x, y|
        active = false;
    })
    .drawFunc_({|v|
        var bounds = v.bounds;
        var center = bounds.extent * 0.5;
        var radius = (bounds.width.min(bounds.height) * 0.45).min(size * 0.45);
        var innerRadius = radius * 0.7;
        var startAngle = -0.75 * pi;
        var endAngle = 0.75 * pi;
        var angle = startAngle + (knobVal * (endAngle - startAngle));
        var indicatorPoint = Point(
            center.x + (radius * 0.85 * cos(angle)),
            center.y + (radius * 0.85 * sin(angle))
        );

        // Draw outer ring
        Pen.strokeColor = ~guiColors.knobStroke;
        Pen.width = 2;
        Pen.addArc(center, radius, startAngle, endAngle - startAngle);
        Pen.stroke;

        // Draw divisions
        8.do {|i|
            var divAngle = startAngle + (i/7) * (endAngle - startAngle);
            var outerPoint = Point(
                center.x + (radius * cos(divAngle)),
                center.y + (radius * sin(divAngle))
            );
            var innerPoint = Point(
                center.x + (radius * 0.9 * cos(divAngle)),
                center.y + (radius * 0.9 * sin(divAngle))
            );
            Pen.line(innerPoint, outerPoint);
        };
        Pen.stroke;

        // Draw filled arc based on value
        Pen.fillColor = ~guiColors.knobFill;
        Pen.addArc(center, innerRadius, startAngle, angle - startAngle);
        Pen.addAnnularWedge(center, 0, innerRadius, startAngle, angle - startAngle);
        Pen.fill;

        // Draw indicator line
        Pen.width = 3;
        if(active) {
            Pen.strokeColor = ~guiColors.highlight;
        } {
            Pen.strokeColor = ~guiColors.knobStroke;
        };
        Pen.line(center, indicatorPoint);
        Pen.stroke;

        // Draw value text in center
        Pen.color = ~guiColors.text;
        Pen.font = Font("Monaco", 10);
        Pen.stringCenteredIn(
            spec.map(knobVal).round(0.01).asString,
            Rect(center.x - 25, center.y - 5, 50, 15)
        );

        // Draw label
        Pen.color = ~guiColors.text;
        Pen.font = Font("Monaco", 12);
        Pen.stringCenteredIn(
            label,
            Rect(center.x - 40, center.y + 20, 80, 20)
        );
    })
    .value_(knobVal);

    knob;
};

// Define the grid layout for knobs
~knobParameters = [
    // Row 1
    [
        \volume,
        \fmratio,
        \fmdepth
    ],
    // Row 2
    [
        \filterfreq,
        \grainsize,
        \graindensity
    ],
    // Row 3
    [
        \pitchoffset,
        \decay,
        \reverbmix
    ]
];

// Populate knob layout
~knobParameters.do {|row, rowIndex|
    row.do {|param, colIndex|
        var name = param;
        var spec = ~controlSpecs[name];
        var initialValue = spec.unmap(~controlValues[name] ? spec.default ? spec.minval);
        var knobView;

        // Create knob
        knobView = ~createOscilloscopeKnob.(
            nil,
            spec,
            initialValue,
            ~displayLabels[name],
            {|val|
                // Update control buses and values
                ~controlBuses[name].setSynchronous(val);
                ~controlValues[name] = val;

                // Update active synths
                if(~currentSynths.notNil) {
                    ~currentSynths.do { |synth|
                        if(synth.notNil and: { synth.isPlaying }) {
                            synth.set(
                                name, val,
                                (name ++ "Bus").asSymbol, ~controlBuses[name].index
                            );
                        };
                    };
                };

                // Update label
                {
                    if(~valueLabels[name].notNil) {
                        ~valueLabels[name].string = val.round(0.001).asString;
                    };
                }.defer;
            }
        );

        // Store reference
        ~knobViews[name] = knobView;

        // Add to grid
        ~knobLayout.add(
            VLayout(
                knobView,
                ~valueLabels[name] = StaticText()
                    .string_(~controlValues[name].asString)
                    .stringColor_(~guiColors.text)
                    .font_(Font("Monaco", 10))
                    .align_(\center)
            ),
            rowIndex, colIndex
        );
    };
};

// Initialize scope data display
~initScopeDisplay = {
    // Create routine to update scope data
    if(~scopeRoutine.notNil) { ~scopeRoutine.stop };

    ~scopeRoutine = Routine {
        var server = Server.default;

        // Wait for server to boot
        server.bootSync;

        // Create buffer for scope data
        if(~scopeBuffer.isNil) {
            ~scopeBuffer = Buffer.alloc(server, 1024);
        };

        loop {
            // Get data from buffer
            ~scopeBuffer.getn(0, 1024, {|data|
                // Downsample for display
                ~scopeData = Array.newFrom(data).resamp1(200);
                {
                    if(~scopeViews.main.notNil) {
                        ~scopeViews.main.refresh;
                    };
                }.defer;
            });

            0.05.wait;  // Update at 20fps
        };
    };

    AppClock.play(~scopeRoutine);
};

// Add status indicators for MIDI connection
~statusLayout = HLayout(
    StaticText()
        .string_("MIDI Status:")
        .stringColor_(~guiColors.text)
        .font_(Font("Monaco", 12)),

    ~midiStatusLabel = StaticText()
        .string_("Initialized")
        .stringColor_(~guiColors.highlight)
        .font_(Font("Monaco", 12)),

    nil,  // Spacer

    StaticText()
        .string_("MIDI Channel:")
        .stringColor_(~guiColors.text)
        .font_(Font("Monaco", 12)),

    StaticText()
        .string_(~midiChannel.asString)
        .stringColor_(~guiColors.highlight)
        .font_(Font("Monaco", 12))
);

// Add status layout to main layout
~mainLayout.insert(~statusLayout, 2);
//)
// SuperCollider Ethereum Sonification - MIDI Controller GUI
// Oscilloscope-inspired visual style
// Part 3: MIDI connection, animations, and final setup

//(
// Add animation to make the interface feel more dynamic
~initAnimations = {
    var counter = 0;

    if(~animationRoutine.notNil) { ~animationRoutine.stop };

    ~animationRoutine = Routine {
        loop {
            counter = counter + 1;

            // Update status indicators
            {
                if(~midiStatusLabel.notNil) {
                    if(counter % 20 == 0) {
                        ~midiStatusLabel.string = "Active";
                        ~midiStatusLabel.stringColor = ~guiColors.highlight;
                    };

                    if(~midiCounter > 0 && ~midiCounter > ~lastMidiCounter) {
                        ~midiStatusLabel.string = "Receiving";
                        ~midiStatusLabel.stringColor = Color.yellow;
                        ~lastMidiCounter = ~midiCounter;
                    };
                };
            }.defer;

            // Animate glow effect for active signals
            if(counter % 5 == 0) {
                {
                    if(~scopeViews.main.notNil) {
                        var val = sin(counter / 20 * pi) * 0.3 + 0.7;
                        ~guiColors.scopeLine = Color(0, val, 0);
                        ~scopeViews.main.refresh;
                    };
                }.defer;
            };

            0.05.wait;
        };
    };

    AppClock.play(~animationRoutine);
};

// Add oscilloscope signal generators for visual feedback
~addSignalGenerators = {
    var signalTypes = [
        \sine, \saw, \square, \noise, \none
    ];
    var currentSignal = \none;
    var signalSynth;

    // Create signal generator layout
    ~signalGenLayout = HLayout(
        StaticText()
            .string_("Signal Generator:")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 12)),

        PopUpMenu()
            .items_(signalTypes.collect(_.asString.capitalize))
            .stringColor_(~guiColors.text)
            .background_(~guiColors.background)
            .action_({|menu|
                var type = signalTypes[menu.value];
                currentSignal = type;

                // Stop existing synth
                if(signalSynth.notNil) {
                    signalSynth.free;
                    signalSynth = nil;
                };

                // Create new synth based on selection
                if(type != \none) {
                    signalSynth = {
                        var sig, freq = ~controlValues[\filterfreq] * ~controlValues[\fmratio];
                        sig = switch(type,
                            \sine, { SinOsc.ar(freq) },
                            \saw, { Saw.ar(freq) },
                            \square, { Pulse.ar(freq) },
                            \noise, { PinkNoise.ar() * 0.5 }
                        );

                        // Apply filter
                        sig = RLPF.ar(
                            sig,
                            ~controlBuses[\filterfreq].kr,
                            0.4
                        );

                        // Apply envelope
                        sig = sig * EnvGen.kr(
                            Env.asr(0.01, 1, ~controlBuses[\decay].kr),
                            gate: 1
                        );

                        // Output to scope bus
                        Out.ar(~scopeBus.index, sig * ~controlBuses[\volume].kr);
                    }.play;
                };
            }),

        nil,  // Spacer

        Button()
            .states_([["Trigger", ~guiColors.text, ~guiColors.knobFill]])
            .action_({
                if(currentSignal != \none) {
                    {
                        var sig = PinkNoise.ar() * Line.kr(1, 0, ~controlValues[\decay]);
                        Out.ar(~scopeBus.index, sig * ~controlValues[\volume]);
                    }.play;
                };
            })
    );

    // Add to main layout
    ~mainLayout.insert(~signalGenLayout, 3);
};

// Add MIDI learn functionality
~addMidiLearn = {
    var currentLearnMode = false;
    var currentLearnParameter = nil;

    // Create MIDI learn button
    ~midiLearnButton = Button()
        .states_([
            ["MIDI Learn", ~guiColors.text, ~guiColors.background],
            ["Learning...", Color.black, ~guiColors.highlight]
        ])
        .action_({|button|
            currentLearnMode = button.value == 1;
            if(currentLearnMode) {
                // Start MIDI learn mode
                ~midiLearnResponder = MIDIFunc.cc({|val, num, chan|
                    if(currentLearnParameter.notNil) {
                        // Update MIDI mapping
                        "MIDI Learn: Parameter % now mapped to CC %".format(
                            currentLearnParameter, num
                        ).postln;

                        // TODO: Update MIDI mappings

                        // Exit learn mode
                        {
                            ~midiLearnButton.value = 0;
                            currentLearnMode = false;
                        }.defer;
                    };
                });
            } {  // Changed 'else' to a single-line format which is more reliable
                // Stop MIDI learn mode
                if(~midiLearnResponder.notNil) { ~midiLearnResponder.free };
                currentLearnParameter = nil;
            };
        });

    // Add click action to knobs for MIDI learn
    ~knobViews.keysValuesDo {|key, knob|
        knob.mouseDownAction = knob.mouseDownAction.addFunc({
            if(currentLearnMode) {
                currentLearnParameter = key;
                "MIDI Learn: Click on knob for parameter %".format(key).postln;
            };
        });
    };

    // Add to status layout
    ~statusLayout.add(~midiLearnButton);
};

// Add tempo sync for oscilloscope
~addTempoSync = {
    var tempoSpec = ControlSpec(60, 180, \lin, 1, 120);
    var tempoKnob;

    // Create tempo controls
    ~tempoLayout = HLayout(
        StaticText()
            .string_("Tempo:")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 12)),

        tempoKnob = Knob()
            .value_(tempoSpec.unmap(120))
            .color_(~guiColors.knobFill, ~guiColors.background, ~guiColors.knobStroke, ~guiColors.highlight)
            .action_({|knob|
                var tempo = tempoSpec.map(knob.value);
                TempoClock.default.tempo = tempo / 60;
                ~tempoLabel.string = tempo.asInteger.asString;
            }),

        ~tempoLabel = StaticText()
            .string_("120")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 12)),

        StaticText()
            .string_("BPM")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 12)),

        Button()
            .states_([["Sync", ~guiColors.text, ~guiColors.knobFill]])
            .action_({
                // Generate tempo-synced waveform
                {
                    var tempo = TempoClock.default.tempo;
                    var sig = SinOsc.ar(tempo * 4) * Line.kr(0.5, 0, 1);
                    Out.ar(~scopeBus.index, sig);
                }.play;
            })
    );

    // Add to main layout
    ~mainLayout.insert(~tempoLayout, 4);
};

// Add preset management
~addPresetManagement = {
    var presets = [
        "Default",
        "Ambient",
        "Rhythmic",
        "Glitchy",
        "Smooth"
    ];

    // Create preset layout
    ~presetLayout = HLayout(
        StaticText()
            .string_("Preset:")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 12)),

        PopUpMenu()
            .items_(presets)
            .stringColor_(~guiColors.text)
            .background_(~guiColors.background)
            .action_({|menu|
                var preset = presets[menu.value];

                // Apply preset values
                switch(preset,
                    "Default", {
                        ~controlValues = (
                            volume: 0.3,
                            fmratio: 1.0,
                            grainsize: 0.1,
                            filterfreq: 1000,
                            pitchoffset: 0,
                            fmdepth: 0.2,
                            graindensity: 10,
                            decay: 1.5,
                            delaymix: 0.2,
                            reverbmix: 0.3
                        );
                    },
                    "Ambient", {
                        ~controlValues = (
                            volume: 0.4,
                            fmratio: 1.5,
                            grainsize: 0.3,
                            filterfreq: 800,
                            pitchoffset: -2,
                            fmdepth: 0.4,
                            graindensity: 25,
                            decay: 2.5,
                            delaymix: 0.6,
                            reverbmix: 0.7
                        );
                    },
                    "Rhythmic", {
                        ~controlValues = (
                            volume: 0.5,
                            fmratio: 2.0,
                            grainsize: 0.05,
                            filterfreq: 1500,
                            pitchoffset: 0,
                            fmdepth: 0.8,
                            graindensity: 40,
                            decay: 0.8,
                            delaymix: 0.4,
                            reverbmix: 0.2
                        );
                    },
                    "Glitchy", {
                        ~controlValues = (
                            volume: 0.35,
                            fmratio: 3.5,
                            grainsize: 0.02,
                            filterfreq: 3000,
                            pitchoffset: 5,
                            fmdepth: 0.9,
                            graindensity: 45,
                            decay: 0.6,
                            delaymix: 0.5,
                            reverbmix: 0.1
                        );
                    },
                    "Smooth", {
                        ~controlValues = (
                            volume: 0.25,
                            fmratio: 0.7,
                            grainsize: 0.2,
                            filterfreq: 600,
                            pitchoffset: -5,
                            fmdepth: 0.1,
                            graindensity: 15,
                            decay: 2.0,
                            delaymix: 0.3,
                            reverbmix: 0.5
                        );
                    }
                );

                // Update controls
                ~controlValues.keysValuesDo {|key, val|
                    ~controlBuses[key].setSynchronous(val);

                    // Update GUI
                    {
                        if(~knobViews[key].notNil) {
                            var unmappedVal = ~controlSpecs[key].unmap(val);
                            ~knobViews[key].value = unmappedVal;
                        };
                        if(~valueLabels[key].notNil) {
                            ~valueLabels[key].string = val.round(0.001).asString;
                        };
                    }.defer;
                };
            }),

        nil,  // Spacer

        Button()
            .states_([["Save", ~guiColors.text, ~guiColors.knobFill]])
            .action_({
                // Save current values to a file
                var filename = "ethsynth_preset_" ++ Date.getDate.stamp ++ ".scd";
                var data = "// Ethereum Sonification Preset\n// " ++ Date.getDate.asString ++ "\n\n";
                data = data ++ "(\n~controlValues = (\n";
                ~controlValues.keysValuesDo {|key, val|
                    data = data ++ "\t" ++ key ++ ": " ++ val ++ ",\n";
                };
                data = data ++ ");\n)";

                File.use(filename, "w", {|file|
                    file.write(data);
                });

                "Preset saved to %".format(filename).postln;
            })
    );

    // Add to main layout
    ~mainLayout.insert(~presetLayout, 5);
};

// Add info display
~addInfoDisplay = {
    var infoLayout = HLayout(
        StaticText()
            .string_("Current Date/Time:")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 10)),

        ~dateTimeLabel = StaticText()
            .string_(Date.getDate.asString)
            .stringColor_(~guiColors.highlight)
            .font_(Font("Monaco", 10)),

        nil,  // Spacer

        StaticText()
            .string_("User:")
            .stringColor_(~guiColors.text)
            .font_(Font("Monaco", 10)),

        StaticText()
            .string_("alejoduque")
            .stringColor_(~guiColors.highlight)
            .font_(Font("Monaco", 10))
    );

    // Create update routine for datetime
    AppClock.sched(0, {
        {
            if(~dateTimeLabel.notNil) {
                ~dateTimeLabel.string = Date.getDate.asString;
            };
        }.defer;
        5;  // Update every 5 seconds
    });

    // Add to main layout
    ~mainLayout.add(infoLayout.margins_(~guiDimensions.margins));
};

// Initialize components
~initScopeDisplay.value;
~initAnimations.value;
~addSignalGenerators.value;
~addMidiLearn.value;
~addTempoSync.value;
~addPresetManagement.value;
~addInfoDisplay.value;

// Set up MIDI update handler
~lastMidiCounter = ~midiCounter;

// Final setup
~window.front;
"Ethereum Sonification GUI started".postln;

// Return window for chaining
~window;
)