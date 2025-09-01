// SuperCollider Ethereum Sonification - Backup Script
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-03 05:52:22
// Current User's Login: alejoduque

/*
This is a backup of the working configuration from March 3rd, 2025.
Includes:
- Working server configuration with 3 audio buses
- Working beat engine with drones
- All control buses and parameters
*/

// ===================== SERVER CONFIGURATION =====================
~serverConfig = (
// Server Configuration Backup
s.waitForBoot({
    // Configure server
    s.options.numBuffers = 1024 * 16;
    s.options.memSize = 8192 * 16;
    s.options.maxNodes = 1024 * 32;
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels = 2;
    
    s.sync;
    
    // Create groups
    ~rootGroup = Group.new;
    ~mainGroup = Group.after(~rootGroup);
    
    // Initialize control values first
    ~controlValues = (
        volume: 0.3,
        fmratio: 1.0,
        grainsize: 0.1,
        filterfreq: 1000
    );
    
    // Create audio buses
    ~audioBuses = (
        main: Bus.audio(s, 2),
        effects: Bus.audio(s, 2),
        transactions: Bus.audio(s, 2)
    );
    
    // Create control buses
    ~controlBuses = (
        volume: Bus.control(s, 1).set(~controlValues.volume),
        fmratio: Bus.control(s, 1).set(~controlValues.fmratio),
        grainsize: Bus.control(s, 1).set(~controlValues.grainsize),
        filterfreq: Bus.control(s, 1).set(~controlValues.filterfreq)
    );
    
    // Audio parameters
    ~audioParams = (
        masterVolume: 0.5,
        transactionVolume: 0.3,
        beatVolume: 0.6
    );
    
    // Control specs for MIDI and GUI
    ~controlSpecs = (
        volume: ControlSpec(0, 1, \lin),
        fmratio: ControlSpec(0.5, 4, \exp),
        grainsize: ControlSpec(0.01, 0.5, \exp),
        filterfreq: ControlSpec(200, 5000, \exp)
    );
    
    // Create monitor synth
    SynthDef(\mainMonitor, {
        arg in=0, out=0, amp=1;
        var sig = In.ar(in, 2) * amp;
        Out.ar(out, sig);
    }).add;
    
    s.sync;
    
    // Create the monitor
    ~mainMonitor = Synth.tail(~rootGroup, \mainMonitor, [
        \in, ~audioBuses.main,
        \out, 0,
        \amp, 1
    ]);
});
);

// ===================== BEAT ENGINE CONFIGURATION =====================
~beatEngineConfig = (
// Beat Engine Configuration Backup
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

// Beat Engine Event Structure
~beatEngine = (
    running: false,
    routine: nil,
    
    start: { |self|
        if(self.running.not) {
            var baseFreqs = [440, 660, 880];
            
            self.running = true;
            self.routine = Routine({
                var lastBeat = 0;
                
                loop {
                    var now = SystemClock.seconds;
                    var timeSinceLastTx = now - (~beatParams.lastTransactionTime ? now);
                    var transactionInfluence = (~beatParams.transactionInfluence * 
                        exp(timeSinceLastTx.neg * 0.5)).clip(0, 1);
                    var freq, amp, dec;
                    
                    // Modulate parameters
                    freq = baseFreqs.choose * 
                        (1 + (transactionInfluence * ~beatParams.transactionDensity * 0.5));
                    
                    amp = ~beatParams.masterAmp * 
                        (0.3 + (transactionInfluence * 0.2));
                    
                    dec = ~beatParams.droneFade * 
                        (1 + (transactionInfluence * 0.5));
                    
                    // Create beat synth
                    Synth(\elektronBell, [
                        \out, ~audioBuses.main,
                        \freq, freq,
                        \amp, amp,
                        \atk, 0.01 * (1 + (transactionInfluence * 0.5)),
                        \dec, dec,
                        \rel, 0.5 * (1 + (transactionInfluence * 0.3)),
                        \tone, ~beatParams.droneRes,
                        \res, ~beatParams.droneRes,
                        \pan, ~beatParams.droneSpace.rand2,
                        \fmRatio, ~beatParams.transactionDensity.linlin(0, 1, 1, 2),
                        \fmDepth, ~beatParams.droneDepth,
                        \grainSize, ~beatParams.noiseFilt,
                        \grainDensity, ~beatParams.noiseLevel * 20
                    ]);
                    
                    (1/~beatParams.beatTempo * 
                        (1 + (transactionInfluence * -0.2))
                    ).wait;
                    
                    lastBeat = now;
                };
            }).play;
        };
    },
    
    stop: { |self|
        if(self.running) {
            self.running = false;
            if(self.routine.notNil) {
                self.routine.stop;
                self.routine = nil;
            };
        };
    }
);
);

// ===================== SYSTEM STATUS =====================
~systemStatus = (
    // Known working values
    mainBusIndex: 4,
    workingAudioBuses: Set[\effects, \transactions, \main],
    workingControlBuses: Set[\volume, \fmratio, \grainsize, \filterfreq],
    timestamp: "2025-03-03 05:52:22"
);

/*
To restore this configuration:
1. Copy the server configuration section to 1_server_config.scd
2. Copy the beat engine configuration section to 5_beat_engine.scd
3. Make sure the elektronBell SynthDef is loaded
4. Run the loader

Known working state:
- Main bus index: 4
- All three audio buses active
- Control buses properly initialized
- Drones working with transaction influence
*/