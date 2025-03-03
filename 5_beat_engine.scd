// SuperCollider Ethereum Sonification - Beat Engine
// Current Date and Time (UTC): 2025-03-02 05:10:58
// Current User's Login: alejoduque
// Initialization: 5/9

(
s.waitForBoot({
    // Beat engine parameters
    ~beatEngine = (
        bpm: 120,
        running: false,
        routine: nil,
        currentBeat: 0,
        beatsPerBar: 4,
        barCount: 0,
        
        start: {
            if(~beatEngine.running.not) {
                ~beatEngine.running = true;
                ~beatEngine.currentBeat = 0;
                ~beatEngine.barCount = 0;
                
                ~beatEngine.routine = Routine({
                    var beatDur = 60/~beatEngine.bpm;
                    
                    inf.do {
                        Synth(\beatSynth, [
                            \freq, 60,
                            \amp, if(~beatEngine.currentBeat == 0, 0.4, 0.2) * 
                                ~audioParams.beatVolume,
                            \out, ~audioBuses.main
                        ], ~mainGroup);
                        
                        ~beatEngine.currentBeat = 
                            (~beatEngine.currentBeat + 1) % ~beatEngine.beatsPerBar;
                            
                        if(~beatEngine.currentBeat == 0) {
                            ~beatEngine.barCount = ~beatEngine.barCount + 1;
                        };
                        
                        beatDur.wait;
                    };
                }).play;
                
                "Beat engine started at % BPM".format(~beatEngine.bpm).postln;
            } {
                "Beat engine already running".warn;
            };
        },
        
        stop: {
            if(~beatEngine.running) {
                ~beatEngine.running = false;
                ~beatEngine.routine.stop;
                ~beatEngine.routine = nil;
                "Beat engine stopped".postln;
            };
        },
        
        cleanup: {
            ~beatEngine.stop;
            "Beat engine cleaned up".postln;
        }
    );
    
    // Start the beat engine
    ~beatEngine.start;
    
    // Register cleanup
    ServerQuit.add({ ~beatEngine.cleanup });
    
    "Beat engine loaded with default parameters.".postln;
});
)