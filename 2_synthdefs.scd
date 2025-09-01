// SuperCollider Ethereum Sonification - Synth Definitions (Modified)
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-12 10:45:00
// Current User's Login: alejoduque

(
// Clear existing definitions
Server.default.quit;
s.waitForBoot({

    // Initialize audio buses if not already defined
    ~audioBuses = ~audioBuses ?? (
        main: Bus.audio(s, 2)    // Main stereo output bus
    );

    // Control buses for MIDI/GUI
    ~controlBuses = ~controlBuses ?? (
        volume: Bus.control(s, 1).set(0.3),
        fmratio: Bus.control(s, 1).set(1.0),
        grainsize: Bus.control(s, 1).set(0.1),
        filterfreq: Bus.control(s, 1).set(1000),
        pitchoffset: Bus.control(s, 1).set(0),
        fmdepth: Bus.control(s, 1).set(0.2),
        graindensity: Bus.control(s, 1).set(10),
        decay: Bus.control(s, 1).set(1.5),
        delaymix: Bus.control(s, 1).set(0.2),
        reverbmix: Bus.control(s, 1).set(0.3)
    );

    // Initialize control values
    ~controlValues = ~controlValues ?? (
        volume: 0.3,
        fmratio: 1.0,
        grainsize: 0.1,
        filterfreq: 1000,
        pitchoffset: 0,
        fmdepth: 0.2,
        graindensity: 10,
        decay: 1.5,
        delaymix: 0.2,
        reverbmix: 0.3
    );

    // Track active synths for parameter updates
    ~currentSynths = ~currentSynths ?? List.new;
    ~noteCounter = ~noteCounter ?? 0;

    // Main transaction synth
    SynthDef(\elektronBell, {
        arg freq=440, amp=0.3,
        atk=0.01, dec=0.3, rel=0.5,
        tone=0.3, res=0.4, pan=0,
        fmRatio=1.0, fmDepth=0.2,
        grainSize=0.1, grainDensity=10,
        filterFreq=1000, delayMix=0.2, reverbMix=0.3,
        volumeBus=0, out=0;

        var env, sig, mod, carrier, grains, wet;

        // Get volume from control bus
        var midiAmp = In.kr(volumeBus, 1);

        // Apply pitch offset
        env = EnvGen.kr(
            Env.new(
                [0, 1, 0.5, 0],
                [atk, dec, rel],
                [-4, -2, -4]
            ),
            doneAction: 2
        );

        // FM Synthesis
        mod = SinOsc.ar(freq * fmRatio) * fmDepth * freq;
        carrier = SinOsc.ar(freq + mod);
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
        sig = sig * (amp * midiAmp);
        sig = Balance2.ar(sig[0], sig[1], pan);

        Out.ar(out, sig);
    }).add;

    // Transaction event synth
    SynthDef(\transactionEvent, {
        arg freq=880, amp=0.5,
        atk=0.001, dec=0.1, rel=0.5,
        filterFreq=3000, res=0.3, pan=0,
        delayAmount=0.2, reverbAmount=0.3,
        volumeBus=0, out=0;

        var env, sig, wet;
        var midiAmp = In.kr(volumeBus, 1);

        // Simple envelope
        env = EnvGen.kr(
            Env.new(
                [0, 1, 0.6, 0],
                [atk, dec, rel],
                [-2, -4, -4]
            ),
            doneAction: 2
        );

        // Simple FM bell
        sig = SinOsc.ar(freq) * SinOsc.ar(freq * 1.5, 0, 0.5) * env;

        // Filter
        sig = RLPF.ar(sig, filterFreq, res);

        // Stereo delay
        wet = DelayN.ar(sig, 0.5, [0.25, 0.35], delayAmount);
        sig = sig + wet;

        // Reverb
        sig = FreeVerb.ar(sig, reverbAmount, 0.7, 0.5);

        // Pan and output
        sig = Pan2.ar(sig, pan, amp * midiAmp);

        Out.ar(out, sig);
    }).add;

    // Helper function to create synths with control buses
    ~createNoteSynth = { |freq=440, amp=0.3, synth=\elektronBell|
        var newSynth = Synth(synth, [
            \freq, freq,
            \amp, amp,
            \volumeBus, ~controlBuses.volume.index,
            \fmRatio, ~controlValues.fmratio,
            \fmDepth, ~controlValues.fmdepth,
            \grainSize, ~controlValues.grainsize,
            \grainDensity, ~controlValues.graindensity,
            \filterFreq, ~controlValues.filterfreq,
            \delayMix, ~controlValues.delaymix,
            \reverbMix, ~controlValues.reverbmix,
            \out, ~audioBuses.main
        ]);

        ~currentSynths.add(newSynth);
        ~noteCounter = (~noteCounter ? 0) + 1;

        newSynth;
    };

    // Helper function to trigger transaction events
    ~triggerTransaction = { |value=0.5, time=nil|
        var density = value.clip(0, 1);
        var txTime = time ? SystemClock.seconds;
        var freq = 880 * (1 + (density * 0.5));

        // Create transaction sound
        ~createNoteSynth.(freq, 0.5 * density, \transactionEvent);

        // Update beat engine parameters
        if(~beatEngine.notNil) {
            ~beatEngine.updateTransaction(txTime, density);
        };
    };

    // Print initialization message
    [
        "Modified Synth Definitions loaded with MIDI/GUI integration",
        "Control Buses initialized with default values.",
        "Ready for ETH transaction sonification."
    ].join("\n").postln;
});
)