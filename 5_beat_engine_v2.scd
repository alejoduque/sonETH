// SuperCollider Ethereum Sonification - Beat Engine
// Current Date and Time (UTC): 2025-03-01 21:35:06
// Current User's Login: alejoduque

(
// Initialize default values with expanded parameter set
~beatParams = (
    // Rhythm parameters
    beatTempo: 1.0,
    
    // Drone parameters
    droneFade: 2.0,
    droneSpace: 0.5,
    droneMix: 0.5,
    droneRes: 0.4,
    droneDepth: 0.3,
    
    // Noise parameters
    noiseLevel: 0.1,
    noiseFilt: 0.5,
    
    // Global parameters
    masterAmp: 0.7,
    delayFeedback: 0.3,
    filterCutoff: 0.6,
    
    // Transaction-influenced parameters
    transactionInfluence: 0.3,  // How much transactions affect the beat
    lastTransactionTime: 0,
    transactionDensity: 0
);

// Initialize control buses if they don't exist
~controlBuses = ~controlBuses ?? ();
~beatParams.keysValuesDo { |key, value|
    ~controlBuses[key] = ~controlBuses[key] ?? { Bus.control(s, 1).set(value) };
};

// Enhanced Beat Engine with transaction influence
~beatEngine = {
    if(~beatRoutine.notNil) { ~beatRoutine.stop };
    
    ~beatRoutine = Routine({
        var baseFreqs = [440, 660, 880];
        var lastBeat = 0;
        var transactionInfluence;
        
        loop {
            var now = SystemClock.seconds;
            var timeSinceLastTx = now - (~beatParams.lastTransactionTime ? now);
            var freq, amp, dec;
            
            // Calculate transaction influence
            transactionInfluence = (~beatParams.transactionInfluence * 
                exp(timeSinceLastTx.neg * 0.5)).clip(0, 1);
            
            // Modulate parameters based on transaction activity
            freq = baseFreqs.choose * 
                (1 + (transactionInfluence * ~beatParams.transactionDensity * 0.5));
            
            amp = ~beatParams.masterAmp * 
                (0.3 + (transactionInfluence * 0.2));
            
            dec = ~beatParams.droneFade * 
                (1 + (transactionInfluence * 0.5));
            
            // Create beat synth with enhanced parameters
            Synth(\elektronBell, [
                \freq, freq,
                \amp, amp,
                \atk, 0.01 * (1 + (transactionInfluence * 0.5)),
                \dec, dec,
                \rel, 0.5 * (1 + (transactionInfluence * 0.3)),
                \tone, ~beatParams.droneRes,
                \res, ~beatParams.droneRes,
                \pan, ~beatParams.droneSpace.rand2,
                
                // Apply MIDI-controlled parameters
                \fmRatio, ~beatParams.transactionDensity.linlin(0, 1, 1, 2),
                \fmDepth, ~beatParams.droneDepth,
                \grainSize, ~beatParams.noiseFilt,
                \grainDensity, ~beatParams.noiseLevel * 20
            ]);
            
            // Dynamic timing based on transaction activity
            (1/~beatParams.beatTempo * 
                (1 + (transactionInfluence * -0.2)) // Slight tempo increase with activity
            ).wait;
            
            lastBeat = now;
        };
    });
    
    ~beatRoutine.play;
};

// Enhanced Beat Controls
~addBeatControls = {
    var controls = ();
    var values = ~beatParams.copy;
    
    if(~beatWindow.notNil and: { ~beatWindow.isClosed.not }) {
        ~beatWindow.close;
    };

    ~beatWindow = Window("Ethereum Beat Controls", Rect(500, 100, 400, 700));
    ~beatWindow.view.decorator = FlowLayout(~beatWindow.bounds, Point(10, 10), Point(10, 5));

    // Enhanced control specifications with grouped parameters
    [
        // Rhythm Section
        [[\beatTempo, [0.5, 2.0, \exp], "Tempo"],
         [\transactionInfluence, [0.0, 1.0, \lin], "TX Influence"]],
        
        // Drone Section
        [[\droneFade, [0.5, 4.0, \exp], "Fade Time"],
         [\droneSpace, [0.0, 1.0, \lin], "Space"],
         [\droneMix, [0.0, 1.0, \lin], "Layer Mix"],
         [\droneRes, [0.1, 0.9, \lin], "Resonance"],
         [\droneDepth, [0.0, 1.0, \lin], "Depth"]],
        
        // Effects Section
        [[\noiseLevel, [0.0, 0.3, \lin], "Noise Level"],
         [\noiseFilt, [0.1, 0.8, \lin], "Noise Filter"],
         [\delayFeedback, [0.0, 0.8, \lin], "Delay Feedback"],
         [\filterCutoff, [0.1, 1.0, \exp], "Filter Cutoff"]],
        
        // Master Section
        [[\masterAmp, [0.0, 1.0, \lin], "Master Level"]]
    ].do { |group|
        // Add group separator
        StaticText(~beatWindow, 380@20)
            .string_("─" * 48)
            .align_(\center);
            
        group.do { |spec|
            var name = spec[0];
            var range = spec[1];
            var label = spec[2];
            
            StaticText(~beatWindow, 380@20)
                .string_(label)
                .align_(\left);
            
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
    };

    // Transaction Monitor Section
    StaticText(~beatWindow, 380@30)
        .string_("Ethereum Transaction Monitor")
        .align_(\center)
        .background_(Color.grey(0.9));

    ~transactionCount = StaticText(~beatWindow, 380@20)
        .string_("Transactions: 0")
        .align_(\center);
        
    ~valueDisplay = StaticText(~beatWindow, 380@20)
        .string_("Last Value: 0 ETH")
        .align_(\center);
        
    ~activityMeter = UserView(~beatWindow, 380@20)
        .drawFunc_({ |view|
            var activity = ~beatParams.transactionDensity;
            Pen.fillColor = Color.blue(0.6, 0.5);
            Pen.fillRect(Rect(0, 0, view.bounds.width * activity, view.bounds.height));
        })
        .animate_(true);

    ~beatWindow.front;
};

// Initialize beat engine
~beatEngine.value;

"Beat engine loaded with transaction influence.".postln;
)