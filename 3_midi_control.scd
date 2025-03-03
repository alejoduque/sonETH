// SuperCollider Ethereum Sonification - MIDI Control System
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-03 01:48:24
// Current User's Login: alejoduque

{
    var success = true;
    
    try {
        // Initialize MIDI system
        "Initializing MIDI system...".postln;
        MIDIClient.init;
        MIDIIn.connectAll;

        // Clear any existing MIDI responders
        MIDIdef.freeAll;

        // Initialize counters and channels
        ~midiCounter = 0;
        ~midiChannel = 14;
        ~midiControl = ();  // Required by loader

        // Initialize control buses if they don't exist
        ~controlBuses = ~controlBuses ?? {
            (
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
            )
        };

        // Initialize control values for GUI sync
        ~controlValues = ~controlValues ?? {
            (
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
            )
        };

        // Define MIDI mappings
        [
            [\volume, 0, 0, 1, \lin],
            [\fmratio, 1, 0.5, 4, \exp],
            [\grainsize, 2, 0.01, 0.5, \exp],
            [\filterfreq, 3, 200, 5000, \exp],
            [\pitchoffset, 4, -12, 12, \lin],
            [\fmdepth, 32, 0, 1, \lin],
            [\graindensity, 33, 5, 50, \exp],
            [\decay, 34, 0.5, 3, \lin],
            [\delaymix, 35, 0, 1, \lin],
            [\reverbmix, 36, 0, 1, \lin]
        ].do { |params|
            var name, cc, min, max, curve;
            #name, cc, min, max, curve = params;
            
            MIDIdef.cc(name, { |val|
                var spec = ControlSpec(min, max, curve);
                var mappedVal = spec.map(val/127);
                ~controlBuses[name].set(mappedVal);
                ~controlValues[name] = mappedVal;
                ~midiCounter = ~midiCounter + 1;
                "MIDI CC: % -> % (mapped: %)".format(name, val, mappedVal).postln;
            }, cc, ~midiChannel);
        };

        "MIDI Control System loaded.".postln;
        true;
    } {
        |error|
        "MIDI initialization error: %".format(error.errorString).error;
        false;
    }
}.value;