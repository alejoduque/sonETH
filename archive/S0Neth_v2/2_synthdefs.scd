// SuperCollider Ethereum Sonification - SynthDef Definitions
// Current Date and Time (UTC): 2025-03-02 01:07:52
// Current User's Login: alejoduque
// Initialization Sequence: 3 of 9

(
s.waitForBoot({
    try {
        // Transaction sonification synth
        SynthDef(\elektronBell, {
            arg freq=440, amp=0.3, atk=0.01, dec=0.3, rel=0.5,
                pan=0, out=0, gate=1;
            
            var env = EnvGen.kr(
                Env.new([0,1,0.5,0], [atk,dec,rel], [-4,-2,-4]),
                gate,
                doneAction: 2
            );
            
            var modEnv = EnvGen.kr(
                Env.perc(atk * 0.5, dec * 0.5),
                gate
            );
            
            var mod = SinOsc.ar(freq * 1.5) * modEnv * 0.5 * freq;
            var sig = SinOsc.ar(freq + mod) * env * amp;
            
            Out.ar(out, Pan2.ar(sig, pan));
        }).add;
        
        s.sync;
        
        SynthDef(\beatSynth, {
            arg freq=80, amp=0.3, decay=0.1, out=0;
            var env = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);
            var sig = SinOsc.ar(freq) * env * amp;
            Out.ar(out, sig ! 2);
        }).add;
        
        s.sync;
        
        SynthDef(\effectProcessor, {
            arg in=0, out=0, mix=0.5, room=0.6, damp=0.2;
            var dry = In.ar(in, 2);
            var wet = FreeVerb.ar(dry, mix, room, damp);
            Out.ar(out, wet);
        }).add;
        
        s.sync;
        
        SynthDef(\masterOut, {
            arg in=0, out=0, amp=1;
            var sig = In.ar(in, 2);
            sig = Compander.ar(sig, sig,
                thresh: 0.5,
                slopeBelow: 1,
                slopeAbove: 0.5,
                clampTime: 0.01,
                relaxTime: 0.1
            );
            Out.ar(out, sig * amp);
        }).add;
        
        s.sync;
        
        // Initialize FX chain
        if(~mainGroup.notNil) {
            ~fxGroup = Group.after(~mainGroup);
            ~masterGroup = Group.after(~fxGroup);
            
            ~effectSynth = Synth(\effectProcessor, [
                \in, ~audioBuses !? {~audioBuses.transactions} ? 0,
                \out, ~audioBuses !? {~audioBuses.main} ? 0,
                \mix, 0.3
            ], ~fxGroup);
            
            ~masterSynth = Synth(\masterOut, [
                \in, ~audioBuses !? {~audioBuses.main} ? 0,
                \out, 0,
                \amp, 1
            ], ~masterGroup);
            
            "SynthDefs loaded successfully.".postln;
        } {
            "Warning: Main group not initialized.".warn;
        };
        
    } { |err|
        "SynthDef loading error: %".format(err.asString).error;
    };
});
)