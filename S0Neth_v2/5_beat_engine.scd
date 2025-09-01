// SuperCollider Ethereum Sonification - Beat Engine
// Current Date and Time (UTC): 2025-03-02 01:05:56
// Current User's Login: alejoduque
// Initialization Sequence: 6 of 9

(
s.waitForBoot({
    var beatEngine;
    
    try {
        beatEngine = (
            bpm: 120,
            running: false,
            routine: nil,
            currentBeat: 0,
            beatsPerBar: 4,
            barCount: 0,
            transactionInfluence: 0,
            
            init: { |self|
                if(s.serverRunning.not) {
                    "Server not running, waiting...".postln;
                    ^false;
                };
                
                if(~mainGroup.isNil) {
                    ~mainGroup = Group.new(s);
                };
                
                "Beat engine initialized.".postln;
                ^true;
            },
            
            getBeatDuration: { |self|
                60 / self.bpm;
            },
            
            triggerBeat: { |self, beatNum|
                if(s.serverRunning && ~mainGroup.notNil) {
                    var baseFreq = 60;
                    var amp = (~audioParams !? {~audioParams.beatVolume} ? 0.5) * 
                        if(beatNum == 0) { 1 } { 0.7 };
                    
                    Synth(\beatSynth, [
                        \freq, baseFreq * (1 + self.transactionInfluence),
                        \amp, amp,
                        \decay, self.getBeatDuration * 0.5,
                        \out, ~audioBuses !? {~audioBuses.main} ? 0
                    ], ~mainGroup);
                };
            },
            
            start: { |self|
                if(self.running) {
                    "Beat engine already running".warn;
                    ^false;
                };
                
                if(s.serverRunning.not) {
                    "Server not running".warn;
                    ^false;
                };
                
                self.running = true;
                self.currentBeat = 0;
                self.barCount = 0;
                
                self.routine = Routine({
                    var beatDur;
                    
                    while { self.running and: { s.serverRunning } } {
                        beatDur = self.getBeatDuration;
                        self.triggerBeat(self.currentBeat);
                        
                        self.currentBeat = (self.currentBeat + 1) % self.beatsPerBar;
                        if(self.currentBeat == 0) { 
                            self.barCount = self.barCount + 1 
                        };
                        
                        beatDur.wait;
                    };
                    
                    self.running = false;
                    "Beat engine stopped due to server status.".postln;
                });
                
                self.routine.play(TempoClock.default);
                "Beat engine started at % BPM".format(self.bpm).postln;
                ^true;
            },
            
            stop: { |self|
                if(self.running) {
                    self.running = false;
                    self.routine !? { self.routine.stop };
                    self.routine = nil;
                    "Beat engine stopped".postln;
                };
            },
            
            setTransactionInfluence: { |self, value|
                self.transactionInfluence = value.clip(0, 1);
            },
            
            cleanup: { |self|
                self.stop;
                "Beat engine cleaned up".postln;
            }
        );
        
        // Store in global variable
        ~beatEngine = beatEngine;
        
        // Initialize and start
        if(~beatEngine.init) {
            ~beatEngine.start;
        };
        
        // Register cleanup
        ServerQuit.add({ 
            ~beatEngine !? { ~beatEngine.cleanup };
        });
        
        // Monitor routine
        ~beatMonitor = Routine({
            while { ~beatEngine.notNil } {
                if(~beatEngine.running) {
                    [
                        "Beat Engine Status:",
                        "- Running: %".format(~beatEngine.running),
                        "- BPM: %".format(~beatEngine.bpm),
                        "- Bar: %".format(~beatEngine.barCount),
                        "- Beat: %".format(~beatEngine.currentBeat),
                        "- Transaction Influence: %".format(~beatEngine.transactionInfluence)
                    ].join("\n").postln;
                };
                2.wait;
            };
        }).play(AppClock);
        
        "Beat engine loaded with transaction influence.".postln;
        
    } { |error|
        "Beat engine initialization error: %".format(error.asString).error;
    };
});
)