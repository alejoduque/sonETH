// SuperCollider Ethereum Sonification - Beat Engine
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-04 00:17:00
// Current User's Login: alejoduque

(
// Initialize beat parameters
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
    filterCutoff: 0.6,
    transactionInfluence: 0.3,
    lastTransactionTime: 0,
    transactionDensity: 0
);

// Beat engine with transaction influence
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
                    
                    freq = baseFreqs.choose * 
                        (1 + (transactionInfluence * ~beatParams.transactionDensity * 0.5));
                    
                    amp = ~beatParams.masterAmp * 
                        (0.3 + (transactionInfluence * 0.2));
                    
                    dec = ~beatParams.droneFade * 
                        (1 + (transactionInfluence * 0.5));
                    
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
                        \grainDensity, ~beatParams.noiseLevel * 20,
                        \volumeBus, ~controlBuses.volume
                    ]);
                    
                    (1/~beatParams.beatTempo * 
                        (1 + (transactionInfluence * -0.2))
                    ).wait;
                    
                    lastBeat = now;
                };
            }).play;
            
            "Beat engine started.".postln;
        } {
            "Beat engine already running".warn;
        };
    },
    
    stop: { |self|
        if(self.running) {
            self.running = false;
            if(self.routine.notNil) {
                self.routine.stop;
                self.routine = nil;
            };
            "Beat engine stopped.".postln;
        };
    },
    
    cleanup: {
        ~beatEngine.stop;
        "Beat engine cleaned up".postln;
    }
);

s.waitForBoot({
    // Start the beat engine
    ~beatEngine.start;
    
    // Register cleanup
    ServerQuit.add({ ~beatEngine.cleanup });
    
    "Beat engine loaded with default parameters.".postln;
});
)