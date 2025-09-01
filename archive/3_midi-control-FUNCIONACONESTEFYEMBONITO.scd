// SuperCollider Ethereum Sonification - MIDI Control System
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-07 00:52:07
// Current User's Login: alejoduque

(
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
        if(~controlBuses.isNil) {
            ~controlBuses = (
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
        };

        // Initialize control values if they don't exist
        if(~controlValues.isNil) {
            ~controlValues = (
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
        };

        // Initialize control specs if they don't exist
        // This should match the specs in the GUI file
        if(~controlSpecs.isNil) {
            ~controlSpecs = (
                volume: ControlSpec(0, 1, \lin),
                fmratio: ControlSpec(0.5, 4, \exp),
                fmdepth: ControlSpec(0, 1, \lin),
                filterfreq: ControlSpec(200, 5000, \exp),
                grainsize: ControlSpec(0.01, 0.5, \exp),
                pitchoffset: ControlSpec(-12, 12, \lin),
                graindensity: ControlSpec(5, 50, \exp),
                decay: ControlSpec(0.5, 3, \lin),
                delaymix: ControlSpec(0, 1, \lin),
                reverbmix: ControlSpec(0, 1, \lin)
            );
        };

        // Initialize synth tracking list if it doesn't exist
        if(~currentSynths.isNil) {
            ~currentSynths = List.new;
        };

        // Define MIDI mappings
        [
            [\volume, 0, 0, 1, \lin],
            [\fmratio, 1, 0.5, 4, \exp],
            [\grainsize, 2, 0.01, 0.5, \exp],
            [\filterfreq, 3, 200, 5000, \exp],
            [\pitchoffset, 4, -12, 12, \lin],
            [\fmdepth, 5, 0, 1, \lin],
            [\graindensity, 38, 5, 50, \exp],
            [\decay, 36, 0.5, 3, \lin],
            [\delaymix, 18, 0, 1, \lin],
            [\reverbmix, 109, 0, 1, \lin]
        ].do { |params|
            var name, cc, min, max, curve;
            #name, cc, min, max, curve = params;

            // Update control specs to ensure consistency
            if(~controlSpecs[name].isNil) {
                ~controlSpecs[name] = ControlSpec(min, max, curve);
            };

            MIDIdef.cc(name, { |val|
                var mappedVal;

                // Use consistent specs for mapping
                mappedVal = ~controlSpecs[name].map(val/127);

                // Immediate bus update
                ~controlBuses[name].setSynchronous(mappedVal);
                ~controlValues[name] = mappedVal;

                // Update any active synths
                ~currentSynths.do { |synth|
                    if(synth.notNil and: { synth