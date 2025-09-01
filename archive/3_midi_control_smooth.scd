// SuperCollider Ethereum Sonification - MIDI Control System
// Current Date and Time (UTC): 2025-03-04 00:55:35
// Current User's Login: alejoduque

// Clear existing MIDI definitions
MIDIdef.freeAll;

// Initialize MIDI if not already done
if(MIDIClient.initialized.not) {
    MIDIClient.init;
    MIDIIn.connectAll;
};

// Global parameters with initial values
~soundParams = (
    // Core parameters (Channel 14, CCs 32-39)
    txVolume: 0.5,      // CC 32
    bellTone: 0.3,      // CC 33
    bellDecay: 1.5,     // CC 34
    bellRes: 0.4,       // CC 35
    delayAmount: 0.2,   // CC 36
    reverbMix: 0.3,     // CC 37
    grainSize: 0.1,     // CC 38
    grainDensity: 10,   // CC 39

    // Additional parameters (Channel 12, CCs 32-39)
    fmDepth: 0.2,       // CC 32
    fmRatio: 1.0,       // CC 33
    filterFreq: 1000,   // CC 34
    playbackRate: 0.8,  // CC 35
    pitchOffset: -12,   // CC 36
    bellSpread: 0.0     // CC 37
);

// Create control buses if not already existing
~buses = ~buses ?? ();
~soundParams.keysValuesDo { |param, val|
    ~buses[param] = ~buses[param] ?? { Bus.control(s, 1).set(val) };
};

// Initialize midiControl for loader check
~midiControl = ();

// Faderfox LC2 MIDI responder for Channel 14 (CCs 32-39)
MIDIdef.cc(\lc2Ch14, { |val, num, chan, src|
    var scaled;
    
    case
    {num == 32} {
        scaled = val.linlin(0, 127, 0.0, 1.0);
        ~buses[\txVolume].setSynchronous(scaled);
        ~soundParams[\txVolume] = scaled;
        {~gui.volumeSlider.value = scaled}.defer;
        "Volume: %".format(scaled.round(0.001)).postln;
    }
    {num == 33} {
        scaled = val.linlin(0, 127, 0.1, 0.8);
        ~buses[\bellTone].setSynchronous(scaled);
        ~soundParams[\bellTone] = scaled;
        "Tone: %".format(scaled.round(0.001)).postln;
    }
    {num == 34} {
        scaled = val.linexp(0, 127, 0.5, 5.0);
        ~buses[\bellDecay].setSynchronous(scaled);
        ~soundParams[\bellDecay] = scaled;
        "Decay: %".format(scaled.round(0.001)).postln;
    }
    {num == 35} {
        scaled = val.linlin(0, 127, 0.0, 0.7);
        ~buses[\delayAmount].setSynchronous(scaled);
        ~soundParams[\delayAmount] = scaled;
        "Delay: %".format(scaled.round(0.001)).postln;
    }
    {num == 36} {
        scaled = val.linlin(0, 127, 0.0, 0.8);
        ~buses[\reverbMix].setSynchronous(scaled);
        ~soundParams[\reverbMix] = scaled;
        "Reverb: %".format(scaled.round(0.001)).postln;
    }
    {num == 37} {
        scaled = val.linexp(0, 127, 200, 5000);
        ~buses[\filterFreq].setSynchronous(scaled);
        ~soundParams[\filterFreq] = scaled;
        "Filter: %".format(scaled.round(0.001)).postln;
    }
    {num == 38} {
        scaled = val.linlin(0, 127, -24, 12);
        ~buses[\pitchOffset].setSynchronous(scaled);
        ~soundParams[\pitchOffset] = scaled;
        "Pitch: %".format(scaled.round(0.001)).postln;
    };
}, nil, 14);

// Channel 12 controls
MIDIdef.cc(\lc2Ch12, { |val, num, chan, src|
    var scaled;
    
    case
    {num == 32} {
        scaled = val.linlin(0, 127, 0.0, 1.0);
        ~buses[\fmDepth].setSynchronous(scaled);
        ~soundParams[\fmDepth] = scaled;
        "FM Depth: %".format(scaled.round(0.001)).postln;
    }
    {num == 33} {
        scaled = val.linexp(0, 127, 0.5, 4.0);
        ~buses[\fmRatio].setSynchronous(scaled);
        ~soundParams[\fmRatio] = scaled;
        "FM Ratio: %".format(scaled.round(0.001)).postln;
    }
    {num == 34} {
        scaled = val.linlin(0, 127, 0.1, 0.9);
        ~buses[\bellRes].setSynchronous(scaled);
        ~soundParams[\bellRes] = scaled;
        "Resonance: %".format(scaled.round(0.001)).postln;
    }
    {num == 35} {
        scaled = val.linlin(0, 127, -1.0, 1.0);
        ~buses[\bellSpread].setSynchronous(scaled);
        ~soundParams[\bellSpread] = scaled;
        "Spread: %".format(scaled.round(0.001)).postln;
    };
}, nil, 12);

// Print available controls
"MIDI Control System loaded.".postln;
"Faderfox LC2 ready on channels 12 and 14:".postln;
"Channel 14:".postln;
"  CC 32: Volume (0-1)".postln;
"  CC 33: Bell Tone (0.1-0.8)".postln;
"  CC 34: Bell Decay (0.5-5.0)".postln;
"  CC 35: Delay Amount (0-0.7)".postln;
"  CC 36: Reverb Mix (0-0.8)".postln;
"  CC 37: Filter Freq (200-5000 Hz)".postln;
"  CC 38: Pitch Offset (-24 to 12)".postln;
"Channel 12:".postln;
"  CC 32: FM Depth (0-1)".postln;
"  CC 33: FM Ratio (0.5-4.0)".postln;
"  CC 34: Bell Resonance (0.1-0.9)".postln;
"  CC 35: Bell Spread (-1 to 1)".postln;