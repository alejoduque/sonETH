// SuperCollider Ethereum Sonification - Synth Definitions
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2024-02-12 22:02:32
// Current User's Login: alejoduque

(
// Main transaction synth - pure definition without MIDI dependencies
SynthDef(\elektronBell, {
    arg freq=440, amp=0.3, 
    atk=0.01, dec=0.3, rel=0.5,
    fmRatio=1.0, fmDepth=0.2,
    grainSize=0.1, grainDensity=10,
    filterFreq=1000, res=0.4,
    decay=1.5, delayMix=0.2, reverbMix=0.3,
    pitchOffset=0, pan=0,
    out=0;

    var env, sig, mod, carrier, grains, wet;
    
    // Apply pitch offset
    freq = freq * pitchOffset.midiratio;
    
    // FM Synthesis
    mod = SinOsc.ar(freq * fmRatio) * fmDepth * freq;
    carrier = SinOsc.ar(freq + mod);
    
    // Envelope
    env = EnvGen.kr(
        Env.new(
            [0, 1, 0.5, 0],
            [atk, dec * decay, rel * decay],
            [-4, -2, -4]
        ),
        doneAction: 2
    );
    
    sig = carrier * env;
    
    // Filter
    sig = RLPF.ar(
        sig,
        filterFreq,
        res
    );
    
    // Granular processing
    grains = GrainIn.ar(
        2,
        Dust.kr(grainDensity),
        grainSize,
        sig,
        pan
    );
    
    sig = XFade2.ar(sig, grains, 0.5);
    
    // Delay
    wet = DelayC.ar(
        sig,
        0.5,
        LFNoise2.kr(0.1).range(0.2, 0.4),
        delayMix
    );
    sig = sig + wet;
    
    // Reverb
    sig = FreeVerb2.ar(
        sig[0], sig[1],
        reverbMix,
        0.7,
        0.5
    );
    
    // Final output
    sig = sig * amp;
    sig = Balance2.ar(sig[0], sig[1], pan);
    
    Out.ar(out, sig);
}).add;

// Beat synth definition
SynthDef(\beatSynth, {
    arg out=0, freq=440, amp=0.5, rel=0.1;
    var env, sig;
    
    env = EnvGen.kr(Env.perc(0.01, rel), doneAction: 2);
    sig = SinOsc.ar(freq) * env * amp;
    
    Out.ar(out, sig!2);
}).add;

"Synth definitions loaded successfully.".postln;
)