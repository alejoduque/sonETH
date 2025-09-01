// SuperCollider Ethereum Sonification - MIDI Control System (Troubleshooting Version)
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-11 00:52:07
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
        // Initialize counters
        ~midiCounter = 0;
        // Remove channel restriction to listen on all channels
        // ~midiChannel = 14;  // Commented out to listen on all channels
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

        // Add diagnostic MIDI CC monitor to see what's actually coming in
        MIDIdef.cc(\debug, { |val, num, chan, src|
            "Received MIDI CC: controller=%, value=%, channel=%, source=%".format(
                num, val, chan, src
            ).postln;
        }, nil, nil); // Listen to all controllers on all channels

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

            // Create a unique responder name to avoid collisions
            var responderName = (name ++ "_responder").asSymbol;

            MIDIdef.cc(responderName, { |val, num, chan, src|
                var mappedVal;
                // Use consistent specs for mapping
                mappedVal = ~controlSpecs[name].map(val/127);

                // Immediate bus update
                ~controlBuses[name].setSynchronous(mappedVal);
                ~controlValues[name] = mappedVal;

                // Update any active synths
                ~currentSynths.do { |synth|
                    if(synth.notNil and: { synth.isPlaying }) {
                        synth.set(
                            (name.asString.toLower ++ "Bus").asSymbol,
                            ~controlBuses[name].index
                        );
                    };
                };

                // Use fork with AppClock for more reliable GUI updates
                {
                    // Add a small delay to ensure GUI stability
                    0.05.wait;

                    // Update knob view if it exists
                    if(~knobViews.notNil and: { ~knobViews[name].notNil }) {
                        ~knobViews[name].value = ~controlSpecs[name].unmap(mappedVal);
                    };

                    // Update label if it exists
                    if(~controlLabels.notNil and: { ~controlLabels[name].notNil } and: { ~displayLabels.notNil }) {
                        ~controlLabels[name].string = ~displayLabels[name] ++ ": " ++ mappedVal.round(0.001);
                    };

                    // Increment MIDI counter for visual feedback
                    ~midiCounter = (~midiCounter ? 0) + 1;
                }.fork(AppClock);

                // Debug output
                "MIDI Controller: % (#%) value: % mapped to %".format(
                    name, num, val, mappedVal.round(0.001)
                ).postln;

            }, cc, nil); // Listen on all channels

            "MIDI controller #% mapped to %".format(cc, name).postln;
        };

        // Add alternative mappings for problematic controllers
        // This creates duplicate responders for these controllers on common alternative numbers
        [
            // Try alternative controller numbers for problematic parameters
            [\fmdepth, 73, 0, 1, \lin],       // Common alternative for fmdepth
            [\graindensity, 74, 5, 50, \exp], // Common alternative for graindensity
            [\decay, 75, 0.5, 3, \lin],       // Common alternative for decay
            [\delaymix, 76, 0, 1, \lin]       // Common alternative for delaymix
        ].do { |params|
            var name, cc, min, max, curve;
            #name, cc, min, max, curve = params;

            // Create a unique responder name with alt suffix
            var responderName = (name ++ "_alt").asSymbol;

            MIDIdef.cc(responderName, { |val, num, chan, src|
                var mappedVal;
                // Use consistent specs for mapping
                mappedVal = ~controlSpecs[name].map(val/127);

                // Immediate bus update
                ~controlBuses[name].setSynchronous(mappedVal);
                ~controlValues[name] = mappedVal;

                // Update any active synths
                ~currentSynths.do { |synth|
                    if(synth.notNil and: { synth.isPlaying }) {
                        synth.set(
                            (name.asString.toLower ++ "Bus").asSymbol,
                            ~controlBuses[name].index
                        );
                    };
                };

                // Use fork with AppClock for more reliable GUI updates
                {
                    // Add a small delay to ensure GUI stability
                    0.05.wait;

                    // Update knob view if it exists
                    if(~knobViews.notNil and: { ~knobViews[name].notNil }) {
                        ~knobViews[name].value = ~controlSpecs[name].unmap(mappedVal);
                    };

                    // Update label if it exists
                    if(~controlLabels.notNil and: { ~controlLabels[name].notNil } and: { ~displayLabels.notNil }) {
                        ~controlLabels[name].string = ~displayLabels[name] ++ ": " ++ mappedVal.round(0.001);
                    };

                    // Increment MIDI counter for visual feedback
                    ~midiCounter = (~midiCounter ? 0) + 1;
                }.fork(AppClock);

                // Debug output
                "MIDI Controller (Alternative): % (#%) value: % mapped to %".format(
                    name, num, val, mappedVal.round(0.001)
                ).postln;

            }, cc, nil); // Listen on all channels

            "Alternative MIDI controller #% mapped to %".format(cc, name).postln;
        };

        // Log MIDI devices for user reference
        "Available MIDI sources:".postln;
        MIDIClient.sources.do { |src, i|
            "  [%] % (%)".format(i, src.device, src.name).postln;
        };

        // Update MIDI status in GUI if available
        if(~statusLights.notNil and: { ~statusLights[\midi].notNil }) {
            {
                ~statusLights[\midi].setProperty(\status, 1);
            }.defer;
        };

        // Helper for manually associating controller numbers with parameters
        ~mapController = { |cc, paramName|
            if(~controlSpecs[paramName].notNil) {
                var responderName = (paramName ++ "_manual").asSymbol;

                MIDIdef.cc(responderName, { |val, num, chan, src|
                    var mappedVal = ~controlSpecs[paramName].map(val/127);

                    ~controlBuses[paramName].setSynchronous(mappedVal);
                    ~controlValues[paramName] = mappedVal;

                    // Update GUI on the AppClock
                    {
                        0.05.wait;
                        if(~knobViews[paramName].notNil) {
                            ~knobViews[paramName].value = ~controlSpecs[paramName].unmap(mappedVal);
                        };
                        if(~controlLabels[paramName].notNil && ~displayLabels[paramName].notNil) {
                            ~controlLabels[paramName].string = ~displayLabels[paramName] ++ ": " ++ mappedVal.round(0.001);
                        };
                        ~midiCounter = (~midiCounter ? 0) + 1;
                    }.fork(AppClock);

                    "Manual MIDI mapping: % (#%) -> %".format(num, val, paramName).postln;
                }, cc, nil);

                "Manual MIDI controller #% mapped to %".format(cc, paramName).postln;
            } {
                "Error: Parameter % not found in control specs".format(paramName).error;
            };
        };

        // Instructions for manual mapping
        "To manually map a controller to a parameter, use:".postln;
        "~mapController.(ccNumber, \\paramName)".postln;
        "Example: ~mapController.(7, \\fmdepth)".postln;

        "MIDI Control System (troubleshooting version) loaded successfully.".postln;
        success;
    } {
        |error|
        "MIDI initialization failed: %".format(error.errorString).error;
        false;
    }
}.value;
)