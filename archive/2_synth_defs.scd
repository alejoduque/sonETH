// SuperCollider Ethereum Sonification - Synth Definitions
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-02 16:34:23
// Current User's Login: alejoduque

(
// Clear existing definitions
Server.default.quit;
s.waitForBoot({
    
    // Initialize audio buses if not already defined
    ~audioBuses = ~audioBuses ?? (
        main: Bus.audio(s, 2)    // Main stereo output bus
    );

    // Control buses for MIDI
    ~controlBuses = ~controlBuses ?? (
        // Channel 14 controls (same as current GUI)
        fmRatio: Bus.control(s, 1).set(1.0),      // CC1
        grainSize: Bus.control(s, 1).set(0.1),    // CC2
        filterFreq: Bus.control(s, 1).set(1000),  // CC3
        pitchOffset: Bus.control(s, 1).set(0),    // CC4

        // Additional parameters with default values
        volume: Bus.control(s, 1).set(0.3),
        fmDepth: Bus.control(s, 1).set(0.2),
        grainDensity: Bus.control(s, 1).set(10),
        decay: Bus.control(s, 1).set(1.5),
        delayMix: Bus.control(s, 1).set(0.2),
        reverbMix: Bus.control(s, 1).set(0.3)
    );

    // Main transaction synth
    SynthDef(\elektronBell, {
        arg freq=440, amp=0.3, 
        atk=0.01, dec=0.3, rel=0.5,
        tone=0.3, res=0.4, pan=0,
        out=0;

        var env, sig, mod, carrier, grains, wet;
        
        // Get MIDI control values
        var midiAmp = In.kr(~controlBuses.volume, 1);
        var midiFMRatio = In.kr(~controlBuses.fmRatio, 1);
        var midiFMDepth = In.kr(~controlBuses.fmDepth, 1);
        var midiGrainSize = In.kr(~controlBuses.grainSize, 1);
        var midiGrainDensity = In.kr(~controlBuses.grainDensity, 1);
        var midiFilterFreq = In.kr(~controlBuses.filterFreq, 1);
        var midiDecay = In.kr(~controlBuses.decay, 1);
        var midiDelayMix = In.kr(~controlBuses.delayMix, 1);
        var midiReverbMix = In.kr(~controlBuses.reverbMix, 1);
        var midiPitchOffset = In.kr(~controlBuses.pitchOffset, 1);
        
        // Apply pitch offset
        freq = freq * midiPitchOffset.midiratio;
        
        // FM Synthesis
        mod = SinOsc.ar(freq * midiFMRatio) * midiFMDepth * freq;
        carrier = SinOsc.ar(freq + mod);
        
        // Envelope
        env = EnvGen.kr(
            Env.new(
                [0, 1, 0.5, 0],
                [atk, dec * midiDecay, rel * midiDecay],
                [-4, -2, -4]
            ),
            doneAction: 2
        );
        
        sig = carrier * env;
        
        // Filter
        sig = RLPF.ar(
            sig,
            midiFilterFreq.linexp(0, 1, 200, 5000),
            res
        );
        
        // Granular processing
        grains = GrainIn.ar(
            2,
            Dust.kr(midiGrainDensity.linexp(0, 1, 5, 50)),
            midiGrainSize,
            sig,
            pan
        );
        
        sig = XFade2.ar(sig, grains, 0.5);
        
        // Delay
        wet = DelayC.ar(
            sig,
            0.5,
            LFNoise2.kr(0.1).range(0.2, 0.4),
            midiDelayMix
        );
        sig = sig + wet;
        
        // Reverb
        sig = FreeVerb2.ar(
            sig[0], sig[1],
            midiReverbMix,
            0.7,
            0.5
        );
        
        // Final output
        sig = sig * (amp * midiAmp);
        sig = Balance2.ar(sig[0], sig[1], pan);
        
        Out.ar(out, sig);
    }).add;

    // MIDI CC handling is now in the interface file
    // Just define default values for parameters
    ~audioParams = ~audioParams ?? (
        beatVolume: 0.3,
        noteVolume: 0.3,
        reverbMix: 0.3,
        delayMix: 0.2
    );

    // Print initialization message
    [
        "Synth Definitions loaded with MIDI mapping",
        "\nMIDI Control Map (Channel 14):",
        "  CC1 -> FM Ratio",
        "  CC2 -> Grain Size",
        "  CC3 -> Filter Freq",
        "  CC4 -> Pitch Offset",
        "\nControl Buses initialized with default values.",
        "Ready for ETH transaction sonification."
    ].join("\n").postln;
});
)