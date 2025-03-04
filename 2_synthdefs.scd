// SuperCollider Ethereum Sonification - Synth Definitions
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
    fmRatioBus=0, fmDepthBus=0,
    grainSizeBus=0, grainDensityBus=0,
    filterFreqBus=0, res=0.4,
    decayBus=0, delayMixBus=0, reverbMixBus=0,
    pitchOffsetBus=0, pan=0,
    out=0,
    volumeBus=0;

    var env, sig, mod, carrier, grains, wet;
    var volume = In.kr(volumeBus, 1);
    var fmRatio = In.kr(fmRatioBus, 1);
    var fmDepth = In.kr(fmDepthBus, 1);
    var grainSize = In.kr(grainSizeBus, 1);
    var grainDensity = In.kr(grainDensityBus, 1);
    var filterFreq = In.kr(filterFreqBus, 1);
    
    // Enhanced FM Synthesis
    mod = SinOsc.ar(freq * fmRatio, 0, fmDepth * 1000);  // Increased modulation depth
    carrier = SinOsc.ar(freq + mod);
    
    // Envelope
    env = EnvGen.kr(
        Env.new(
            [0, 1, 0.5, 0],
            [atk, dec, rel],
            [-4, -2, -4]
        ),
        doneAction: 2
    );
    
    sig = carrier * env;
    
    // Filter with wider range
    sig = RLPF.ar(
        sig,
        filterFreq.linexp(0, 1, 200, 8000),
        res
    );
    
    // Granular processing with more presence
    grains = GrainIn.ar(
        2,
        Dust.kr(grainDensity * 20),  // Increased density range
        grainSize.linlin(0, 1, 0.01, 0.2),
        sig,
        pan
    );
    
    sig = XFade2.ar(sig, grains, 0);  // Less grain mix for clearer sound
    
    // Final output with volume control
    sig = sig * amp * volume;
    sig = Balance2.ar(sig, sig, pan);
    
    Out.ar(out, sig);
}).add;

// Beat synth definition
SynthDef(\beatSynth, {
    arg out=0, freq=440, amp=0.5, rel=0.1, volumeBus=0;
    var env, sig;
    var volume = In.kr(volumeBus, 1);
    
    env = EnvGen.kr(Env.perc(0.01, rel), doneAction: 2);
    sig = SinOsc.ar(freq) * env * amp * volume;
    
    Out.ar(out, sig!2);
}).add;

s.sync;

// Create the main monitor instance
~mainMonitor.free;
~mainMonitor = Synth.tail(s, \mainMonitor, [
    \inMain, ~audioBuses.main,
    \inTrans, ~audioBuses.transactions,
    \inEffects, ~audioBuses.effects,
    \out, 0,
    \amp, 1
]);

"Synth definitions loaded successfully.".postln;
)