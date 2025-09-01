// SuperCollider Ethereum Sonification - Beat Engine
// Current Date and Time (UTC): 2025-03-01 21:48:06
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
    transactionInfluence: 0.3,
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
            
            // Create beat synth with real-time bus connections
            {
                var beatSynthArgs = [
                    \freq, freq,
                    \amp, amp * 0.7,  // Slightly reduced for cleaner mix
                    \atk, 0.01 * (1 + (transactionInfluence * 0.5)),
                    \dec, dec,
                    \rel, 0.5 * (1 + (transactionInfluence * 0.3)),
                    \tone, ~beatParams.droneRes,
                    \res, ~beatParams.droneRes,
                    \pan, ~beatParams.droneSpace.rand2
                ];
                
                // Connect ALL control buses to beat synths too
                if(~buses.notNil) {
                    ~buses.keysValuesDo { |paramName, bus|
                        var busParamName = (paramName.asString ++ "Bus").asSymbol;
                        beatSynthArgs = beatSynthArgs ++ [busParamName, bus.index];
                    };
                };
                
                Synth(\elektronBell, beatSynthArgs);
            }.value;
            
            // Dynamic timing based on transaction activity
            (1/~beatParams.beatTempo * 
                (1 + (transactionInfluence * -0.2)) // Slight tempo increase with activity
            ).wait;
            
            lastBeat = now;
        };
    });
    
    ~beatRoutine.play;
};

// Enhanced Beat Controls with fixed GUI
~addBeatControls = {
    var controls = ();
    var values = ~beatParams.copy;
    
    if(~beatWindow.notNil and: { ~beatWindow.isClosed.not }) {
        ~beatWindow.close;
    };

    ~beatWindow = Window("Ethereum Beat Controls", Rect(500, 100, 400, 700));
    ~beatWindow.view.decorator = FlowLayout(~beatWindow.bounds, Point(10, 10), Point(10, 5));

    // Parameter groups
    [
        // Group 1: Rhythm
        ["RHYTHM", [
            [\beatTempo, [0.5, 2.0, \exp], "Tempo"],
            [\transactionInfluence, [0.0, 1.0, \lin], "TX Influence"]
        ]],
        
        // Group 2: Drone
        ["DRONE", [
            [\droneFade, [0.5, 4.0, \exp], "Fade Time"],
            [\droneSpace, [0.0, 1.0, \lin], "Space"],
            [\droneMix, [0.0, 1.0, \lin], "Layer Mix"],
            [\droneRes, [0.1, 0.9, \lin], "Resonance"],
            [\droneDepth, [0.0, 1.0, \lin], "Depth"]
        ]],
        
        // Group 3: Effects
        ["EFFECTS", [
            [\noiseLevel, [0.0, 0.3, \lin], "Noise Level"],
            [\noiseFilt, [0.1, 0.8, \lin], "Noise Filter"],
            [\delayFeedback, [0.0, 0.8, \lin], "Delay Feedback"],
            [\filterCutoff, [0.1, 1.0, \exp], "Filter Cutoff"]
        ]],
        
        // Group 4: Master
        ["MASTER", [
            [\masterAmp, [0.0, 1.0, \lin], "Master Level"]
        ]]
    ].do { |group|
        var groupName = group[0];
        var params = group[1];
        
        // Add group header
        StaticText(~beatWindow, 380@25)
            .string_(groupName)
            .align_(\center)
            .background_(Color.grey(0.9));
            
        params.do { |spec|
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
        
        // Add spacing between groups
        StaticText(~beatWindow, 380@10);
    };

    // Transaction Monitor
    StaticText(~beatWindow, 380@30)
        .string_("TRANSACTION MONITOR")
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