// SuperCollider Ethereum Sonification - Enhanced MIDI Control System
// Last updated: 2025-02-28

(
// Expanded global sound parameters with additional controls
~soundParams = (
    // Original parameters
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
    maxGap: 2.0,
    
    // New parameters for FM synthesis
    fmIndex: 3.0,
    fmRatio: 2.0,
    fmFeedback: 0.1,
    fmHarmonics: 0.7,
    
    // New parameters for bell synth
    bellFreqScale: 0.5,  // Scale down frequencies to reduce high pitches
    bellNoiseAmount: 0.2,
    bellAttack: 0.005,
    bellOctave: -1,      // Lower octave for less piercing sounds
    
    // Beat parameters
    beatTempo: 1.0,
    beatComplexity: 0.5,
    beatVariation: 0.3,
    
    // Drone parameters
    droneLevel: 0.3,
    droneFilterFreq: 800,
    droneRes: 0.3,
    droneFade: 1.5,
    droneDepth: 0.5,
    
    // Transaction sonification
    txProbability: 1.0,   // Probability of a transaction triggering a sound
    txDensity: 0.7,       // Control how many transactions trigger sounds
    txPitchSpread: 0.5    // Spread of pitches for transaction sounds
);

// MIDI mapping - maps CC numbers to parameter names for easy lookup
~midiMapping = (
    // Channel 12: Main Sound Controls (32-49)
    12: (
        32: \txVolume,
        33: \bellTone,
        34: \bellDecay,
        35: \bellRes,
        36: \playbackRate,
        37: \delayAmount,
        38: \reverbMix,
        39: \bellSpread,
        40: \bellFreqScale,    // New - controls bell frequency scaling
        41: \bellNoiseAmount,  // New - controls noise mix in bells
        42: \bellAttack,       // New - controls bell attack time
        43: \bellOctave,       // New - controls bell octave shift
        44: \txProbability,    // New - probability of transaction sounds
        45: \txPitchSpread,    // New - controls pitch spread
        46: \txDensity,        // New - controls transaction sound density
        47: \delayTime,        // New - controls delay time
        48: \bufferSize,       // New - controls buffer size
        49: \minGap            // New - controls minimum gap between sounds
    ),
    
    // Channel 14: FM and Beat Controls (32-49)
    14: (
        32: \fmIndex,         // FM modulation index
        33: \fmRatio,         // FM carrier/modulator ratio
        34: \fmFeedback,      // FM feedback amount
        35: \fmHarmonics,     // FM harmonic content
        36: \beatTempo,       // Beat tempo control
        37: \beatComplexity,  // Beat complexity
        38: \beatVariation,   // Beat variation
        39: \droneLevel,      // Drone level
        40: \droneFilterFreq, // Drone filter frequency
        41: \droneRes,        // Drone resonance
        42: \droneFade,       // Drone fade time
        43: \droneDepth,      // Drone modulation depth
        44: \maxGap,          // Maximum gap between sounds
        45: \masterAmp,       // Master amplitude
        46: \noiseLevel,      // Background noise level
        47: \noiseFilt,       // Noise filter
        48: \droneSpace,      // Drone spatial spread
        49: \droneMix         // Drone layer mix
    )
);

// Parameter scaling functions - maps MIDI values (0-127) to appropriate parameter ranges
~parameterScaling = (
    txVolume: [0.0, 1.0, \lin],
    bellTone: [0.1, 0.8, \lin],
    bellDecay: [0.5, 5.0, \exp],
    bellRes: [0.1, 0.9, \lin],
    bellSpread: [-1.0, 1.0, \lin],
    delayAmount: [0.0, 0.8, \lin],
    delayTime: [0.1, 1.0, \exp],
    reverbMix: [0.0, 0.8, \lin],
    playbackRate: [0.1, 2.0, \exp],
    bufferSize: [20, 200, \lin],
    minGap: [0.05, 0.5, \exp],
    maxGap: [0.5, 4.0, \exp],
    fmIndex: [0.5, 8.0, \exp],
    fmRatio: [0.5, 6.0, \exp],
    fmFeedback: [0.0, 0.5, \lin],
    fmHarmonics: [0.0, 1.0, \lin],
    bellFreqScale: [0.1, 1.0, \exp],
    bellNoiseAmount: [0.0, 0.6, \lin],
    bellAttack: [0.001, 0.05, \exp],
    bellOctave: [-2, 1, \lin],
    txProbability: [0.1, 1.0, \lin],
    txDensity: [0.1, 1.0, \lin],
    txPitchSpread: [0.0, 1.0, \lin],
    beatTempo: [0.5, 2.0, \exp],
    beatComplexity: [0.0, 1.0, \lin],
    beatVariation: [0.0, 1.0, \lin],
    droneLevel: [0.0, 0.6, \lin],
    droneFilterFreq: [200, 2000, \exp],
    droneRes: [0.1, 0.9, \lin],
    droneFade: [0.5, 4.0, \exp],
    droneDepth: [0.0, 1.0, \lin],
    masterAmp: [0.0, 1.0, \lin],
    noiseLevel: [0.0, 0.3, \lin],
    noiseFilt: [0.1, 0.8, \lin],
    droneSpace: [0.0, 1.0, \lin],
    droneMix: [0.0, 1.0, \lin]
);

~midiSystem = (
    init: { |self|
        "Initializing Enhanced MIDI System...".postln;
        
        MIDIdef.freeAll;
        
        if(MIDIClient.initialized.not) {
            MIDIClient.init;
            MIDIIn.connectAll;
        };

        self.createResponders();
        self.createBuses();
        
        "Enhanced MIDI System Initialized - channels 12 and 14 mapped to expanded controls".postln;
    },

    createBuses: {
        ~buses = ~buses ?? ();
        ~soundParams.keysValuesDo { |param, val|
            ~buses[param] = Bus.control(s, 1).set(val);
            ("Created bus for % with initial value %".format(param, val)).postln;
        };
    },

    createResponders: {
        // Handle all MIDI CCs on channels 12 and 14
        [12, 14].do { |chan|
            MIDIdef.cc(("enhancedControls" ++ chan).asSymbol, { |val, num, ch, src|
                var mappedParam, scaling, scaledValue;
                
                // Map MIDI CC to parameter
                mappedParam = ~midiMapping[ch][num];
                
                if(mappedParam.notNil) {
                    // Get scaling for this parameter
                    scaling = ~parameterScaling[mappedParam];
                    
                    if(scaling.notNil) {
                        // Scale MIDI value to parameter range
                        scaledValue = val.linlin(0, 127, scaling[0], scaling[1]);
                        
                        // Update parameter value
                        ~soundParams[mappedParam] = scaledValue;
                        
                        // Update control bus
                        if(~buses[mappedParam].notNil) {
                            ~buses[mappedParam].set(scaledValue);
                        };
                        
                        // Apply parameter changes to running synths
                        self.applyParameterChange(mappedParam, scaledValue);
                        
                        // Update GUI if available
                        self.updateGUI(mappedParam, scaledValue);
                        
                        "MIDI CC % on channel % -> Parameter: % = %".format(
                            num, ch, mappedParam, scaledValue.round(0.001)
                        ).postln;
                    };
                };
            }, (32..49), chan);
        };
        
        // Handle MIDI note messages for triggering and testing sounds
        [12, 14].do { |chan|
            MIDIdef.noteOn(("noteControl" ++ chan).asSymbol, { |vel, note|
                var freq = note.midicps;
                
                // Different types of test sounds based on note range
                case 
                { note < 48 } {
                    // Low range: Test bell sounds
                    freq = freq * ~soundParams.bellFreqScale * (2 ** ~soundParams.bellOctave);
                    
                    Synth(\elektronBell, [
                        \freq, freq,
                        \amp, vel.linlin(0, 127, 0.1, 0.5) * ~soundParams.txVolume,
                        \dec, ~soundParams.bellDecay,
                        \rel, ~soundParams.bellDecay * 2,
                        \ffreq, freq * 3 * ~soundParams.bellTone,
                        \rq, ~soundParams.bellRes,
                        \noiseMix, ~soundParams.bellNoiseAmount,
                        \atk, ~soundParams.bellAttack,
                        \pan, ~soundParams.bellSpread.rand2
                    ]);
                    
                    "Test bell - Freq: %, Decay: %, Tone: %".format(
                        freq.round(0.1), ~soundParams.bellDecay, ~soundParams.bellTone
                    ).postln;
                }
                { note < 72 } {
                    // Mid range: Test FM sounds
                    Synth(\fmEngine, [
                        \freq, freq,
                        \amp, vel.linlin(0, 127, 0.1, 0.5) * ~soundParams.txVolume,
                        \atk, ~soundParams.bellAttack * 2,
                        \rel, ~soundParams.bellDecay,
                        \mRatio, ~soundParams.fmRatio,
                        \index, ~soundParams.fmIndex,
                        \feedback, ~soundParams.fmFeedback,
                        \harmonics, ~soundParams.fmHarmonics,
                        \pan, ~soundParams.bellSpread.rand2
                    ]);
                    
                    "Test FM - Freq: %, Index: %, Ratio: %".format(
                        freq.round(0.1), ~soundParams.fmIndex, ~soundParams.fmRatio
                    ).postln;
                }
                { note >= 72 } {
                    // High range: Test drone sounds
                    Synth(\responsiveDrone, [
                        \freq, freq,
                        \amp, vel.linlin(0, 127, 0.1, 0.3) * ~soundParams.droneLevel,
                        \sustain, ~soundParams.droneFade * vel.linlin(0, 127, 1, 3),
                        \res, ~soundParams.droneRes,
                        \depth, ~soundParams.droneDepth,
                        \pan, ~soundParams.bellSpread.rand2
                    ]);
                    
                    "Test drone - Freq: %, Fade: %, Depth: %".format(
                        freq.round(0.1), ~soundParams.droneFade, ~soundParams.droneDepth
                    ).postln;
                };
            }, nil, chan);
        };
        
        // Add note off handling if needed
        // MIDIdef.noteOff...
        
        MIDIFunc.trace(true);
    },
    
    // Method to apply parameter changes to running synths
    applyParameterChange: { |self, param, value|
        // Handle special cases for parameters that need to affect running synths
        switch(param,
            \beatTempo, {
                if(~currentClock.notNil) {
                    ~currentClock.tempo = value;
                };
            },
            \noiseLevel, {
                if(~backgroundNoise.notNil) {
                    ~backgroundNoise.set(\amp, value);
                };
            },
            \noiseFilt, {
                if(~backgroundNoise.notNil) {
                    ~backgroundNoise.set(\filtRes, value);
                };
            },
            \droneFilterFreq, {
                if(~backgroundNoise.notNil) {
                    ~backgroundNoise.set(\filtFreq, value);
                };
            },
            \droneLevel, {
                if(~atmosphereDrones.notNil) {
                    ~atmosphereDrones.do { |drone|
                        if(drone.notNil and: { drone.isPlaying }) {
                            drone.set(\amp, value);
                        };
                    };
                };
            },
            \masterAmp, {
                // Update all drones in the pool with new amplitude
                if(~dronePool.notNil) {
                    ~dronePool.do { |drone|
                        if(drone.notNil and: { drone.isPlaying }) {
                            drone.set(\amp, value * ~soundParams[\droneMix]);
                        };
                    };
                };
                
                // Also update atmosphere drones
                if(~atmosphereDrones.notNil) {
                    ~atmosphereDrones.do { |drone|
                        if(drone.notNil and: { drone.isPlaying }) {
                            drone.set(\amp, value * 0.12);
                        };
                    };
                };
            }
        );
        
        // Update the beatEngine parameters for future transactions
        if(~midi.notNil) {
            ~midi[param] = value;
        };
    },
    
    // Method to update GUI elements based on parameter changes
    updateGUI: { |self, param, value|
        // Defer GUI updates to avoid threading issues
        {
            // Update specific GUI controls if they exist
            switch(param,
                \txVolume, {
                    if(~volumeSlider.notNil and: { ~volumeSlider.isClosed.not }) {
                        ~volumeSlider.value = value.linlin(~parameterScaling[param][0], ~parameterScaling[param][1], 0, 1);
                    };
                },
                \bellTone, {
                    if(~toneSlider.notNil and: { ~toneSlider.isClosed.not }) {
                        ~toneSlider.value = value.linlin(~parameterScaling[param][0], ~parameterScaling[param][1], 0, 1);
                    };
                }
                // Add more cases for other GUI elements here
            );
            
            // Update control panel if available
            if(~beatWindow.notNil and: { ~beatWindow.isClosed.not }) {
                // Find the control that corresponds to this parameter
                if(~controls.notNil and: { ~controls[param].notNil }) {
                    ~controls[param].value = value.linlin(
                        ~parameterScaling[param][0], 
                        ~parameterScaling[param][1], 
                        0, 1
                    );
                };
                
                // Update the value display
                if(~values.notNil and: { ~values[param].notNil }) {
                    ~values[param].string = format("% : %", param, value.round(0.001));
                };
            };
        }.defer;
    },
    
    // Save MIDI mappings to disk
    saveMappings: {
        var path = "~/eth_sonification_midi_mappings.scd".standardizePath;
        var file = File(path, "w");
        
        if(file.isOpen) {
            file.write("// Ethereum Sonification MIDI Mappings\n");
            file.write("// Generated: %\n\n".format(Date.getDate));
            file.write("(\n");
            file.write("~midiMapping = %;\n".format(~midiMapping.asCompileString));
            file.write("~parameterScaling = %;\n".format(~parameterScaling.asCompileString));
            file.write("~soundParams = %;\n".format(~soundParams.asCompileString));
            file.write(");\n");
            file.close;
            
            "MIDI Mappings saved to %".format(path).postln;
        } {
            "Failed to save MIDI mappings".warn;
        };
    },
    
    // Load MIDI mappings from disk
    loadMappings: {
        var path = "~/eth_sonification_midi_mappings.scd".standardizePath;
        
        if(File.exists(path)) {
            "Loading MIDI mappings from %".format(path).postln;
            path.load;
            
            // Update buses with loaded values
            ~soundParams.keysValuesDo { |param, val|
                if(~buses[param].notNil) {
                    ~buses[param].set(val);
                };
            };
            
            "MIDI Mappings loaded".postln;
        } {
            "No saved MIDI mappings found".warn;
        };
    }
);

// Setup the enhanced MIDI control system
~setupEnhancedMidiControl = {
    // Initialize the MIDI system
    ~midiSystem.init();
    
    // Create or update midi dictionary for compatibility with existing code
    ~midi = ~midi ?? ();
    ~soundParams.keysValuesDo { |k, v|
        ~midi[k] = v;
    };
    
    // Add save/load methods to global namespace
    ~saveMidiMappings = { ~midiSystem.saveMappings() };
    ~loadMidiMappings = { ~midiSystem.loadMappings() };
};

// Improved transaction sonification function that uses the enhanced parameters
~triggerTransactionSound = { |txHash, value, gasPrice, type|
    var baseFreq, synth, pan, vel, inst;
    
    // Only trigger sound based on probability
    if(~soundParams.txProbability.coin) {
        // Calculate base frequency based on transaction value and hash
        baseFreq = value.linexp(0.001, 100, 100, 1000);
        baseFreq = baseFreq * ~soundParams.bellFreqScale * (2 ** ~soundParams.bellOctave);
        
        // Add some variation based on hash
        baseFreq = baseFreq * (1 + (txHash.asInteger.fold(0, 100) / 1000 * ~soundParams.txPitchSpread));
        
        // Determine pan position
        pan = (txHash.asInteger.fold(0, 100) / 50 - 1) * ~soundParams.bellSpread;
        
        // Calculate velocity based on transaction size
        vel = value.linlin(0.001, 10, 40, 100);
        
        // Determine which instrument to use based on transaction type and value
        if(type == 1 and: { value > 5 }) {
            // Large transfers use bell synth
            synth = Synth(\elektronBell, [
                \freq, baseFreq,
                \amp, vel.linlin(0, 127, 0.1, 0.5) * ~soundParams.txVolume,
                \dec, ~soundParams.bellDecay * (1 + (gasPrice / 10)),
                \rel, ~soundParams.bellDecay * 2,
                \ffreq, baseFreq * 3 * ~soundParams.bellTone,
                \rq, ~soundParams.bellRes,
                \noiseMix, ~soundParams.bellNoiseAmount,
                \atk, ~soundParams.bellAttack,
                \pan, pan
            ]);
            inst = "bell";
        } {
            if(type == 0 or: { gasPrice > 5 }) {
                // Contract interactions or high gas use FM synth
                synth = Synth(\fmEngine, [
                    \freq, baseFreq * 0.5,  // Lower octave for FM to be less piercing
                    \amp, vel.linlin(0, 127, 0.1, 0.4) * ~soundParams.txVolume,
                    \atk, ~soundParams.bellAttack * 5,
                    \rel, ~soundParams.bellDecay * 0.8,
                    \mRatio, ~soundParams.fmRatio * (1 + (gasPrice / 20)),
                    \cRatio, 1 + (txHash.asInteger.fold(0, 3) * 0.25),
                    \index, ~soundParams.fmIndex * (1 + (value / 20)),
                    \feedback, ~soundParams.fmFeedback * (1 + (gasPrice / 10)),
                    \harmonics, ~soundParams.fmHarmonics,
                    \pan, pan
                ]);
                inst = "fm";
            } {
                // Small regular transactions use a gentler sound
                synth = Synth(\responsiveDrone, [
                    \freq, baseFreq * 0.25,  // Much lower for drones
                    \amp, vel.linlin(0, 127, 0.05, 0.2) * ~soundParams.txVolume * ~soundParams.droneLevel,
                    \sustain, ~soundParams.droneFade * (1 + (value / 5)),
                    \res, ~soundParams.droneRes,
                    \depth, ~soundParams.droneDepth * (1 + (gasPrice / 10)),
                    \pan, pan
                ]);
                inst = "drone";
            };
        };
        
        // Store transaction in history for visualization
        ~txHistory[~txHistoryIndex] = (
            hash: txHash,
            value: value,
            gasPrice: gasPrice,
            type: type,
            freq: baseFreq,
            synth: inst
        );
        ~txHistoryIndex = (~txHistoryIndex + 1) % 100;
        
        // Update display and stats
        ~txCount = (~txCount ? 0) + 1;
        ~totalEth = (~totalEth ? 0) + value;
        
        // Update gas stats
        ~gasStats.min = min(~gasStats.min, gasPrice);
        ~gasStats.max = max(~gasStats.max, gasPrice);
        ~gasStats.avg = (~gasStats.avg * (~txCount - 1) + gasPrice) / ~txCount;
        
        // Update value stats
        ~valueStats.min = min(~valueStats.min, value);
        ~valueStats.max = max(~valueStats.max, value);
        ~valueStats.avg = (~valueStats.avg * (~txCount - 1) + value) / ~txCount;
        
        // Log the transaction sound generation
        "Tx Sound: % | % ETH | % gwei | % | Freq: %".format(
            txHash[0..7], 
            value.round(0.001), 
            gasPrice.round(0.01), 
            inst,
            baseFreq.round(0.1)
        ).postln;
        
        // Update transaction display
        ~updateTransactionDisplay.(txHash, value, gasPrice, type);
        
        // Signal to beat engine that a new transaction occurred
        ~newTransaction = true;
        ~lastTransactionValue = value;
    };
};

// Override the existing setup functions to use our enhanced system
~setupMidiControl = {
    ~setupEnhancedMidiControl.value;
    "Enhanced MIDI control system activated".postln;
};

"Enhanced MIDI Control System loaded - use ~setupEnhancedMidiControl.value; to initialize".postln;
)