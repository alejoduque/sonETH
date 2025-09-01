// SuperCollider Ethereum Sonification - MIDI Control System
// Current Date and Time (UTC): 2025-03-01 02:42:46
// Current User's Login: alejoduque

(
// Global sound parameters
~soundParams = (
    txVolume: 0.5,
    bellTone: 0.3,
    bellDecay: 1.5,
    bellRes: 0.4,
    bellSpread: 0.5,
    delayAmount: 0.2,
    delayTime: 0.4,
    reverbMix: 0.3,
    playbackRate: 0.8,
    bufferSize: 100,
    minGap: 0.2,
    maxGap: 2.0
);

~midiSystem = (
    init: { |self|
        "Initializing MIDI System...".postln;
        
        MIDIdef.freeAll;
        
        if(MIDIClient.initialized.not) {
            MIDIClient.init;
            MIDIIn.connectAll;
        };

        self.createResponders();
        self.createBuses();
        
        "MIDI System Initialized on channels 12 and 14".postln;
    },

    createBuses: {
        ~buses = ~buses ?? ();
        ~soundParams.keysValuesDo { |param, val|
            ~buses[param] = Bus.control(s, 1).set(val);
            ("Created bus for % with initial value %".format(param, val)).postln;
        };
    },

    createResponders: {
        // Listen on both channels 12 and 14
        [12, 14].do { |chan|
            // CC numbers 32-39
            MIDIdef.cc(("encoders" ++ chan).asSymbol, { |val, num, ch, src|
                ["MIDI received:", val, num, ch, src].postln;
                
                switch(num,
                    32, {
                        var scaled = val.linlin(0, 127, 0.0, 1.0);
                        ~soundParams.txVolume = scaled;
                        ~buses[\txVolume].set(scaled);
                        { ~volumeSlider.value = scaled }.defer;
                        "Volume: %".format(scaled.round(0.01)).postln;
                    },
                    33, {
                        var scaled = val.linlin(0, 127, 0.1, 0.8);
                        ~soundParams.bellTone = scaled;
                        ~buses[\bellTone].set(scaled);
                        { ~toneSlider.value = scaled }.defer;
                        "Tone: %".format(scaled.round(0.01)).postln;
                    },
                    34, {
                        var scaled = val.linlin(0, 127, 0.5, 3.0);
                        ~soundParams.bellDecay = scaled;
                        ~buses[\bellDecay].set(scaled);
                        { ~decaySlider.value = scaled }.defer;
                        "Decay: %".format(scaled.round(0.01)).postln;
                    },
                    35, {
                        var scaled = val.linlin(0, 127, 0.1, 0.9);
                        ~soundParams.bellRes = scaled;
                        ~buses[\bellRes].set(scaled);
                        { ~resSlider.value = scaled }.defer;
                        "Resonance: %".format(scaled.round(0.01)).postln;
                    },
                    36, {
                        var scaled = val.linlin(0, 127, 0.1, 2.0);
                        ~soundParams.playbackRate = scaled;
                        ~buses[\playbackRate].set(scaled);
                        if(~txBuffer.notNil) { ~txBuffer.playbackRate = scaled };
                        { ~rateSlider.value = scaled }.defer;
                        "Playback Rate: %".format(scaled.round(0.01)).postln;
                    },
                    37, {
                        var scaled = val.linlin(0, 127, 0.0, 0.8);
                        ~soundParams.delayAmount = scaled;
                        ~buses[\delayAmount].set(scaled);
                        { ~delayKnob.value = scaled }.defer;
                        "Delay Amount: %".format(scaled.round(0.01)).postln;
                    },
                    38, {
                        var scaled = val.linlin(0, 127, 0.0, 0.8);
                        ~soundParams.reverbMix = scaled;
                        ~buses[\reverbMix].set(scaled);
                        { ~reverbKnob.value = scaled }.defer;
                        "Reverb Mix: %".format(scaled.round(0.01)).postln;
                    },
                    39, {
                        var scaled = val.linlin(0, 127, -1.0, 1.0);
                        ~soundParams.bellSpread = scaled;
                        ~buses[\bellSpread].set(scaled);
                        { ~spreadKnob.value = scaled }.defer;
                        "Bell Spread: %".format(scaled.round(0.01)).postln;
                    }
                );
            }, (32..39), chan);
        };

        MIDIFunc.trace(true);
    }
);

~setupMidiControl = {
    ~midiSystem.init();
};

"MIDI Control System loaded - use ~setupMidiControl.value; to initialize".postln;
)