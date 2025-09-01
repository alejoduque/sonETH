// SuperCollider Ethereum Sonification - MIDI Control for Faderfox LC2
// Current Date and Time (UTC): 2025-03-01 00:45:05
// Current User's Login: alejoduque

(
// Faderfox LC2 specific MIDI mappings
~faderfoxLC2 = (
    // LC2 has 4 channels (A,B,C,D) with 8 controls each
    channelA: (
        faders: (16..23),    // CC numbers for channel A faders
        encoders: (0..7)     // CC numbers for channel A encoders
    ),
    channelB: (
        faders: (24..31),    // CC numbers for channel B faders
        encoders: (8..15)    // CC numbers for channel B encoders
    ),
    channelC: (
        faders: (32..39),    // CC numbers for channel C faders
        encoders: (16..23)   // CC numbers for channel C encoders
    ),
    channelD: (
        faders: (40..47),    // CC numbers for channel D faders
        encoders: (24..31)   // CC numbers for channel D encoders
    )
);

// Initialize MIDI control with Faderfox LC2 mappings
~setupMidiControl = {
    // Initialize MIDI parameters with default values
    ~midi = (
        // Channel A - Main Controls
        beatTempo: 1.0,      // Fader 1 (CC 16)
        masterAmp: 0.8,      // Fader 2 (CC 17)
        droneSpace: 0.6,     // Fader 3 (CC 18)
        droneMix: 0.5,       // Fader 4 (CC 19)
        
        // Channel B - Drone Controls
        droneRes: 0.4,       // Fader 1 (CC 24)
        droneDepth: 0.5,     // Fader 2 (CC 25)
        droneFade: 2.0,      // Fader 3 (CC 26)
        delayFeedback: 0.3,  // Fader 4 (CC 27)
        
        // Channel C - Filter Controls
        filterCutoff: 0.5,   // Fader 1 (CC 32)
        noiseLevel: 0.15,    // Fader 2 (CC 33)
        noiseFilt: 0.3,      // Fader 3 (CC 34)
        
        // Channel D - Additional Controls
        fmIndex: 3.0,        // Fader 1 (CC 40)
        fmFeedback: 0.1,     // Fader 2 (CC 41)
        bellDecay: 2.5,      // Fader 3 (CC 42)
        bellResonance: 0.7   // Fader 4 (CC 43)
    );

    // Debug function
    ~midiDebug = { |cc, val, chan|
        "[Faderfox LC2] Channel: %, CC: %, Value: %".format(chan, cc, val).postln;
    };

    // MIDI CC handler specifically for Faderfox LC2
    MIDIdef.cc(\faderfoxLC2, { |val, num, chan|
        var normalizedVal = val/127;
        ~midiDebug.value(num, val, chan);

        case
        // Channel A (Main Controls)
        { ~faderfoxLC2.channelA.faders.includes(num) } {
            switch(num,
                16, { // Tempo
                    ~midi.beatTempo = normalizedVal.linexp(0, 1, 0.5, 2.0);
                    if(~currentClock.notNil) { ~currentClock.tempo = ~midi.beatTempo };
                    "Tempo: %".format(~midi.beatTempo).postln;
                },
                17, { // Master Volume
                    ~midi.masterAmp = normalizedVal;
                    ~updateMasterVolume.value(normalizedVal);
                },
                18, { // Drone Space
                    ~midi.droneSpace = normalizedVal;
                    ~updateDroneSpace.value(normalizedVal);
                },
                19, { // Drone Mix
                    ~midi.droneMix = normalizedVal;
                    ~updateDroneMix.value(normalizedVal);
                }
            );
        }

        // Channel B (Drone Controls)
        { ~faderfoxLC2.channelB.faders.includes(num) } {
            switch(num,
                24, { // Drone Resonance
                    ~midi.droneRes = normalizedVal;
                    ~updateDroneResonance.value(normalizedVal);
                },
                25, { // Drone Depth
                    ~midi.droneDepth = normalizedVal;
                    ~updateDroneDepth.value(normalizedVal);
                },
                26, { // Drone Fade
                    ~midi.droneFade = normalizedVal.linexp(0, 1, 0.5, 4.0);
                },
                27, { // Delay Feedback
                    ~midi.delayFeedback = normalizedVal;
                    ~updateDelayFeedback.value(normalizedVal);
                }
            );
        }

        // Channel C (Filter Controls)
        { ~faderfoxLC2.channelC.faders.includes(num) } {
            switch(num,
                32, { // Filter Cutoff
                    ~midi.filterCutoff = normalizedVal;
                    ~updateFilterCutoff.value(normalizedVal);
                },
                33, { // Noise Level
                    ~midi.noiseLevel = normalizedVal;
                    ~updateNoiseLevel.value(normalizedVal);
                },
                34, { // Noise Filter
                    ~midi.noiseFilt = normalizedVal;
                    ~updateNoiseFilter.value(normalizedVal);
                }
            );
        }

        // Channel D (Additional Controls)
        { ~faderfoxLC2.channelD.faders.includes(num) } {
            switch(num,
                40, { // FM Index
                    ~midi.fmIndex = normalizedVal.linexp(0, 1, 1, 8);
                    ~updateFMIndex.value(normalizedVal);
                },
                41, { // FM Feedback
                    ~midi.fmFeedback = normalizedVal;
                    ~updateFMFeedback.value(normalizedVal);
                },
                42, { // Bell Decay
                    ~midi.bellDecay = normalizedVal.linexp(0, 1, 1, 5);
                    ~updateBellDecay.value(normalizedVal);
                },
                43, { // Bell Resonance
                    ~midi.bellResonance = normalizedVal;
                    ~updateBellResonance.value(normalizedVal);
                }
            );
        };

        // Update GUI if it exists
        {
            if(~beatWindow.notNil and: { ~beatWindow.isClosed.not }) {
                ~updateGuiControls.value;
            };
        }.defer;
    });

    // Update functions for parameters
    ~updateMasterVolume = { |val|
        if(~atmosphereDrones.notNil) {
            ~atmosphereDrones.do(_.set(\amp, val * 0.5));
        };
        if(~backgroundNoise.notNil) {
            ~backgroundNoise.set(\amp, ~midi.noiseLevel * val);
        };
    };

    ~updateDroneSpace = { |val|
        if(~atmosphereDrones.notNil) {
            ~atmosphereDrones.do({ |syn, i|
                syn.set(\pan, val.linlin(0, 1, -1, 1) * [1, -1, 0.5, -0.5][i]);
            });
        };
    };

    // Connect all MIDI sources
    MIDIIn.connectAll;
    
    // Print available MIDI sources to verify Faderfox LC2
    "Available MIDI Sources:".postln;
    MIDIClient.sources.do({ |src, i|
        "Source %: % - %".format(i, src.device, src.name).postln;
    });
};

// Initialize MIDI
~setupMidiControl.value;
"Faderfox LC2 MIDI control system initialized.".postln;
)