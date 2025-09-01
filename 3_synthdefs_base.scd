// SuperCollider Ethereum Sonification - SynthDefs
// Last updated: 2025-02-28 22:46:30 UTC
// Author: alejoduque

(
// Modified Elektron-style bell synth with longer release tail
SynthDef(\elektronBell, { |freq=600, amp=0.3, atk=0.005, dec=1.2, rel=3.0, ffreq=2000, rq=0.3, pan=0, noiseMix=0.2|
    var ping, noise, env, sig;

    env = EnvGen.kr(
        Env.new([0, 1, 0.7, 0], [atk, dec*0.4, dec*0.6 + rel], [2, -3, -5]),
        doneAction: 2
    );

    ping = Mix.ar([
        SinOsc.ar(freq * LFNoise1.kr(0.1).range(0.99, 1.01), 0, 0.8),
        SinOsc.ar(freq * 1.5 * LFNoise1.kr(0.1).range(0.98, 1.02), 0, 0.5),
        SinOsc.ar(freq * 2.2 * LFNoise1.kr(0.1).range(0.97, 1.03), 0, 0.3),
        SinOsc.ar(freq * 3.1 * LFNoise1.kr(0.1).range(0.96, 1.04), 0, 0.15),
        SinOsc.ar(freq * 4.2 * LFNoise1.kr(0.1).range(0.98, 1.02), 0, 0.08)
    ]);

    noise = Mix.ar([
        LPF.ar(PinkNoise.ar, 800) * 0.4,
        BPF.ar(PinkNoise.ar, freq * 2, 0.6) * 0.3,
        HPF.ar(Dust2.ar(freq/50), 800) * 0.1
    ]);

    sig = XFade2.ar(ping, noise, noiseMix * 2 - 1);
    sig = RLPF.ar(
        sig,
        ffreq * env.pow(0.7) * LFNoise2.kr(freq/300).range(0.8, 1.2),
        rq * LFNoise2.kr(0.05).range(0.9, 1.1)
    );

    sig = (sig * (1 + (env.pow(1.5) * 0.7))).tanh * 0.9;
    sig = sig + CombL.ar(sig, 0.05, min(freq.reciprocal, 0.05) * [1, 1.01], dec * 0.8) * 0.25;
    sig = Pan2.ar(sig * env * amp, pan);
    Out.ar(0, sig);
}).add;

// FM synthesis engine with enhanced sustain and feedback
SynthDef(\fmEngine, { |freq=440, amp=0.3, atk=0.01, rel=1, mRatio=2, cRatio=1, index=3, feedback=0.1, pan=0, harmonics=0.7|
    var mod, car, env, feedMod, sig;

    env = EnvGen.kr(Env([0, 1, 0.7, 0], [atk, rel*0.3, rel*1.2], [2, 0, -3]), doneAction: 2);
    feedMod = LocalIn.ar(1) * feedback * env * 3;

    mod = SinOsc.ar(
        freq * mRatio * LFNoise1.kr(0.2).range(0.97, 1.03) + (feedMod * 30),
        0,
        index * env * LFNoise1.kr(0.3).range(0.8, 1.2)
    );

    car = SinOsc.ar(
        freq * cRatio + (mod * freq * LFNoise1.kr(0.1).range(0.8, 1.2)),
        feedMod * 0.2,
        env
    );

    LocalOut.ar(car * 0.3);

    sig = car +
        (SinOsc.ar(freq * 2.01) * env * 0.1 * harmonics) +
        (SinOsc.ar(freq * 3.52) * env * 0.07 * harmonics) +
        (SinOsc.ar(freq * 5.17) * env * 0.04 * harmonics);

    sig = RLPF.ar(
        sig,
        LFNoise2.kr(0.2).range(freq, freq * 8) * env.pow(LFNoise1.kr(0.1).range(0.3, 0.7)),
        LFNoise1.kr(0.1).range(0.1, 0.5)
    );

    sig = (sig * (1 + (env * 0.3))).tanh * 0.9;
    sig = Pan2.ar(sig * amp, pan);
    Out.ar(0, sig);
}).add;

// Background noise generator with modulated filters
SynthDef(\backgroundNoise, { |out=0, amp=0.15, filtFreq=800, filtRes=0.3|
    var sig, lfo1, lfo2, lfo3;
    lfo1 = LFNoise2.kr(0.05).range(0.3, 1);
    lfo2 = LFNoise2.kr(0.03).range(0.7, 1.3);
    lfo3 = SinOsc.kr(0.02).range(0.2, 1);

    sig = Mix([
        PinkNoise.ar(0.6),
        BrownNoise.ar(0.3),
        GrayNoise.ar(0.1)
    ]);

    sig = RLPF.ar(sig, filtFreq * lfo2, filtRes * lfo1);
    sig = HPF.ar(sig, 40 * lfo3);
    sig = LPF.ar(sig, 12000 * lfo1);
    sig = sig * amp;

    Out.ar(out, PanAz.ar(4, sig, LFNoise2.kr(0.03)));
}).add;

// Atmosphere drone with multiple oscillators
SynthDef(\atmosphereDrone, { |out=0, freq=100, amp=0.3, gate=1|
    var env, sig, numOsc=8;
    env = EnvGen.kr(Env.asr(12, 1, 15), gate);

    sig = Mix.fill(numOsc, { |i|
        var f = freq * (1 + (i * 0.02));
        var rate = ExpRand(0.01, 0.08);
        var phase = LFNoise2.kr(rate);
        var amp = LFNoise2.kr(rate * 0.3).range(0.3, 1);

        SinOsc.ar(
            f * LFNoise2.kr(rate * 0.5).range(0.995, 1.005),
            phase,
            amp
        ) * (1/numOsc)
    });

    sig = RLPF.ar(sig,
        freq * 3 * LFNoise2.kr(0.07).range(0.8, 1.2),
        LFNoise2.kr(0.1).range(0.3, 0.7)
    );

    sig = sig * env * amp;
    Out.ar(out, PanAz.ar(4, sig, LFNoise2.kr(0.02)));
}).add;

// Responsive drone with depth control
SynthDef(\responsiveDrone, { |out=0, freq=200, amp=0.3, sustain=12.0, pan=0, res=0.3, depth=0.5|
    var env, sig, numOsc=6, lfo;
    env = EnvGen.kr(
        Env([0, 1, 0.8, 0.8, 0], [3, sustain*0.4, sustain*0.4, 4], [\sin, \sin, 0, \sin]),
        doneAction: 2
    );

    lfo = LFNoise2.kr(Array.fill(numOsc, { ExpRand(0.02, 0.08) }));

    sig = Mix.fill(numOsc, { |i|
        var f = freq * (1 + (i * 0.02)) * (1 + (lfo[i] * depth * 0.01));
        var amp = LFNoise2.kr(0.05 + (i * 0.01)).range(0.6, 1);

        SinOsc.ar(f, 0, amp)
    }) * (1/numOsc);

    sig = RLPF.ar(sig,
        freq * 2 * LFNoise2.kr(0.08).range(0.9, 1.1),
        res * LFNoise2.kr(0.06).range(0.9, 1.1)
    );

    sig = sig * env * amp;
    Out.ar(out, PanAz.ar(4, sig, pan + (LFNoise2.kr(0.05) * 0.2)));
}).add;
)