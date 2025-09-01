// SuperCollider Ethereum Sonification - Synth Definitions
// Current Date and Time (UTC): 2024-03-01 03:33:30
// Current User's Login: alejoduque

/*(
// Clear existing definitions
Server.default.quit;
s.waitForBoot({

    // MIDI-controlled global parameters
    ~globalParams = (
        // Channel 14, First Row (CC 0-7)
        volume: 0.3,          // CC 0  - Overall volume
        fmRatio: 1.0,         // CC 1  - FM frequency ratio
        grainSize: 0.1,       // CC 2  - Granular size
        filterFreq: 1000,     // CC 3  - Filter cutoff
        pitchOffset: -24,     // CC 4  - Transpose

        // Channel 14, Second Row (CC 32-39)
        fmDepth: 0.2,         // CC 32 - FM modulation depth
        grainDensity: 10,     // CC 33 - Grain density
        decay: 1.5,           // CC 34 - Sound decay
        delayMix: 0.2,        // CC 35 - Delay amount
        reverbMix: 0.3,       // CC 36 - Reverb mix

        // Channel 12 Controls
        playbackRate: 0.8,    // CC 0  - Transaction playback rate
        minGap: 0.2,          // CC 1  - Minimum gap between sounds
    );

    // Main transaction bell with MIDI control
    SynthDef(\elektronBell, {
        arg freq=440, amp=0.3,
        atk=0.01, dec=0.3, rel=0.5,
        tone=0.3, res=0.4, pan=0;

        var env, sig, mod, carrier, grains, wet;
        var midiAmp = In.kr(~buses[\volume].index, 1);
        var midiFMRatio = In.kr(~buses[\fmRatio].index, 1);
        var midiFMDepth = In.kr(~buses[\fmDepth].index, 1);
        var midiGrainSize = In.kr(~buses[\grainSize].index, 1);
        var midiGrainDensity = In.kr(~buses[\grainDensity].index, 1);
        var midiFilterFreq = In.kr(~buses[\filterFreq].index, 1);
        var midiDecay = In.kr(~buses[\decay].index, 1);
        var midiDelayMix = In.kr(~buses[\delayMix].index, 1);
        var midiReverbMix = In.kr(~buses[\reverbMix].index, 1);

        // Apply MIDI-controlled pitch offset
        freq = freq * In.kr(~buses[\pitchOffset].index, 1).midiratio;

        // FM Synthesis with MIDI control
        mod = SinOsc.ar(freq * midiFMRatio) * midiFMDepth * freq;
        carrier = SinOsc.ar(freq + mod);

        // Envelope with MIDI-controlled decay
        env = EnvGen.kr(
            Env.new(
                [0, 1, 0.5, 0],
                [atk, dec * midiDecay, rel * midiDecay],
                [-4, -2, -4]
            ),
            doneAction: 2
        );

        sig = carrier * env;

        // Filter with MIDI control
        sig = RLPF.ar(
            sig,
            midiFilterFreq.linexp(0, 1, 200, 5000),
            res
        );

        // Granular processing with MIDI control
        grains = GrainIn.ar(
            2,
            Dust.kr(midiGrainDensity.linexp(0, 1, 5, 50)),
            midiGrainSize,
            sig,
            pan
        );

        sig = XFade2.ar(sig, grains, 0.5);

        // Delay with MIDI control
        wet = DelayC.ar(
            sig,
            0.5,
            LFNoise2.kr(0.1).range(0.2, 0.4),
            midiDelayMix
        );
        sig = sig + wet;

        // Reverb with MIDI control
        sig = FreeVerb2.ar(
            sig[0], sig[1],
            midiReverbMix,
            0.7,
            0.5
        );

        // Final output with MIDI-controlled amplitude
        sig = sig * (amp * midiAmp);
        sig = Balance2.ar(sig[0], sig[1], pan);

        Out.ar(0, sig);
    }).add;

    // Create control buses for MIDI
    ~buses = ~buses ?? ();
    ~globalParams.keysValuesDo { |param, val|
        ~buses[param] = Bus.control(s, 1).set(val);
    };

    "Synth Definitions loaded with MIDI mapping".postln;

    // Print MIDI control map
    "MIDI Control Map:".postln;
    "Channel 14, First Row:".postln;
    "  CC 0  -> Volume".postln;
    "  CC 1  -> FM Ratio".postln;
    "  CC 2  -> Grain Size".postln;
    "  CC 3  -> Filter Freq".postln;
    "  CC 4  -> Pitch Offset".postln;
    "\nChannel 14, Second Row:".postln;
    "  CC 32 -> FM Depth".postln;
    "  CC 33 -> Grain Density".postln;
    "  CC 34 -> Decay Time".postln;
    "  CC 35 -> Delay Mix".postln;
    "  CC 36 -> Reverb Mix".postln;
    "\nChannel 12:".postln;
    "  CC 0  -> Playback Rate".postln;
    "  CC 1  -> Minimum Gap".postln;
});
)*/




