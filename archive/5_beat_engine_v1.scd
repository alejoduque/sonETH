// SuperCollider Ethereum Sonification - Beat Engine
// Current Date and Time (UTC): 2025-03-01 05:12:19
// Current User's Login: alejoduque

(
// Initialize default values
~beatParams = (
    beatTempo: 1.0,
    droneFade: 2.0,
    droneSpace: 0.5,
    droneMix: 0.5,
    droneRes: 0.4,
    droneDepth: 0.3,
    noiseLevel: 0.1,
    noiseFilt: 0.5,
    masterAmp: 0.7,
    delayFeedback: 0.3,
    filterCutoff: 0.6
);

// Initialize control buses if they don't exist
~controlBuses = ~controlBuses ?? ();
~beatParams.keysValuesDo { |key, value|
    ~controlBuses[key] = ~controlBuses[key] ?? { Bus.control(s, 1).set(value) };
};

// Beat Engine
~beatEngine = {
    if(~beatRoutine.notNil) { ~beatRoutine.stop };
    
    ~beatRoutine = Routine({
        var tempo = ~beatParams.beatTempo;
        
        loop {
            Synth(\elektronBell, [
                \freq, 440 * [1, 1.5, 2].choose,
                \amp, ~beatParams.masterAmp * 0.3,
                \dec, ~beatParams.droneFade,
                \pan, ~beatParams.droneSpace.rand2
            ]);
            
            (1/tempo).wait;
        };
    });
    
    ~beatRoutine.play;
};

// Add Beat Controls
~addBeatControls = {
    var controls = ();
    var values = ~beatParams.copy;
    
    if(~beatWindow.notNil and: { ~beatWindow.isClosed.not }) {
        ~beatWindow.close;
    };

    ~beatWindow = Window("Ethereum Beat Controls", Rect(500, 100, 400, 600));
    ~beatWindow.view.decorator = FlowLayout(~beatWindow.bounds, Point(10, 10), Point(10, 5));

    // Control specifications
    [
        [\beatTempo, [0.5, 2.0, \exp], "Tempo"],
        [\droneFade, [0.5, 4.0, \exp], "Fade Time"],
        [\droneSpace, [0.0, 1.0, \lin], "Space"],
        [\droneMix, [0.0, 1.0, \lin], "Layer Mix"],
        [\droneRes, [0.1, 0.9, \lin], "Resonance"],
        [\droneDepth, [0.0, 1.0, \lin], "Depth"],
        [\noiseLevel, [0.0, 0.3, \lin], "Noise Level"],
        [\noiseFilt, [0.1, 0.8, \lin], "Noise Filter"],
        [\masterAmp, [0.0, 1.0, \lin], "Master Level"],
        [\delayFeedback, [0.0, 0.8, \lin], "Delay Feedback"],
        [\filterCutoff, [0.1, 1.0, \exp], "Filter Cutoff"]
    ].do { |spec|
        var name = spec[0];
        var range = spec[1];
        var label = spec[2];
        
        StaticText(~beatWindow, 380@20).string_(label);
        
        controls[name] = Slider(~beatWindow, 380@20)
            .value_(values[name].linlin(range[0], range[1], 0, 1))
            .action_({ |sl|
                var mappedValue = sl.value.linlin(0, 1, range[0], range[1]);
                values[name] = mappedValue;
                ~beatParams[name] = mappedValue;
                ~controlBuses[name].set(mappedValue);
                if(name == \beatTempo) {
                    ~beatEngine.value;
                };
            });
    };

    // Add transaction monitor
    StaticText(~beatWindow, 380@30)
        .string_("Ethereum Transaction Monitor")
        .align_(\center)
        .background_(Color.grey(0.9));

    ~transactionCount = StaticText(~beatWindow, 380@20)
        .string_("Transactions: 0")
        .align_(\center);

    ~beatWindow.front;
};

"Beat engine loaded.".postln;
)