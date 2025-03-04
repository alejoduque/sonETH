// SuperCollider Ethereum Sonification - Synth Definitions
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-03 23:57:35
// Current User's Login: alejoduque

(
// Monitor synth for main output
SynthDef(\mainMonitor, {
    arg inMain=0, inTrans=0, inEffects=0, out=0, amp=1;
    var main = In.ar(inMain, 2);
    var trans = In.ar(inTrans, 2);
    var effects = In.ar(inEffects, 2);
    var mix = Mix([main, trans, effects]) * amp;
    Out.ar(out, mix);
}).add;

// Main transaction synth
SynthDef(\elektronBell, {
    arg freq=440, amp=0.3, 
    atk=0.01, dec=0.3, rel=0.5,
    fmRatio=1.0, fmDepth=0.2,
    grainSize=0.1, grainDensity=10,
    filterFreq=1000, res=0.4,
    decay=1.5, delayMix=0.2, reverbMix=0.3,
    pitchOffset=0, pan=0,
    out=0,
    volumeBus=0;  // Add volume bus input

    var env, sig, mod, carrier, grains, wet;
    var volume = In.kr(volumeBus, 1);  // Read from volume bus
    
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
    
    // Final output with volume control
    sig = sig * amp * volume;
    sig = Balance2.ar(sig[0], sig[1], pan);
    
    Out.ar(out, sig);
}).add;

// Beat synth definition with volume control
SynthDef(\beatSynth, {
    arg out=0, freq=440, amp=0.5, rel=0.1, volumeBus=0;
    var env, sig;
    var volume = In.kr(volumeBus, 1);
    
    env = EnvGen.kr(Env.perc(0.01, rel), doneAction: 2);
    sig = SinOsc.ar(freq) * env * amp * volume;
    
    Out.ar(out, sig!2);
}).add;

// Test synth with volume control
SynthDef(\testBeep, {
    arg out=0, freq=440, amp=0.2, volumeBus=0;
    var env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);
    var volume = In.kr(volumeBus, 1);
    var sig = SinOsc.ar(freq) * env * amp * volume;
    Out.ar(out, sig!2);
}).add;

s.sync;

// Create the main monitor instance
~mainMonitor.free; // Free any existing monitor
~mainMonitor = Synth.tail(~rootGroup, \mainMonitor, [
    \inMain, ~audioBuses.main,
    \inTrans, ~audioBuses.transactions,
    \inEffects, ~audioBuses.effects,
    \out, 0,
    \amp, 1
]);

// Test the routing
{
    // Test through main bus
    Synth(\testBeep, [
        \out, ~audioBuses.main,
        \freq, 440,
        \amp, 0.3,
        \volumeBus, ~controlBuses.volume
    ]);
    
    1.wait;
    
    // Test through transaction bus
    Synth(\testBeep, [
        \out, ~audioBuses.transactions,
        \freq, 880,
        \amp, 0.3,
        \volumeBus, ~controlBuses.volume
    ]);
    
}.fork;

"Synth definitions and monitoring system loaded successfully.".postln;
)