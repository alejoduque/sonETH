// SuperCollider Ethereum Sonification - Synth Definitions
// Current Date and Time (UTC): 2025-03-01 05:04:34
// Current User's Login: alejoduque

(
SynthDef(\elektronBell, {
    arg freq=440, amp=0.3, 
    atk=0.01, dec=0.3, rel=0.5,
    tone=0.3, res=0.4, pan=0;

    var env, sig, mod, carrier;
    
    // FM synthesis
    mod = SinOsc.ar(freq * In.kr(~buses[\fmRatio].index)) * 
          (freq * In.kr(~buses[\fmDepth].index));
    carrier = SinOsc.ar(freq + mod);
    
    // Envelope
    env = EnvGen.kr(
        Env.new(
            [0, 1, 0.5, 0],
            [atk, dec * In.kr(~buses[\decay].index), rel],
            [-4, -2, -4]
        ),
        doneAction: 2
    );
    
    sig = carrier * env;
    
    // Filter
    sig = RLPF.ar(
        sig,
        In.kr(~buses[\filterFreq].index).clip(20, 20000),
        res
    );
    
    // Effects
    sig = sig + LocalIn.ar(2);
    sig = DelayN.ar(sig, 0.2, 0.2 * In.kr(~buses[\delayMix].index));
    LocalOut.ar(sig * 0.4);
    
    sig = FreeVerb.ar(
        sig,
        In.kr(~buses[\reverbMix].index),
        0.7,
        0.5
    );
    
    // Output
    sig = sig * (amp * In.kr(~buses[\volume].index));
    sig = Balance2.ar(sig[0], sig[1], pan);
    
    Out.ar(0, sig);
}).add;

"SynthDefs loaded.".postln;
)