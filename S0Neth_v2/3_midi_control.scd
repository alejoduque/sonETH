// SuperCollider Ethereum Sonification - MIDI Control Configuration
// Current Date and Time (UTC): 2025-03-01 22:40:06
// Current User's Login: alejoduque
// Initialization Sequence: 4 of 9
// Depends on: 0_init.scd, 1_server_config.scd, 2_synthdefs.scd
// Required by: none

(
// Initialize MIDI
MIDIClient.init;
MIDIIn.connectAll;

// MIDI Control mapping
~midiControl = (
    channel14: (
        // First row CC numbers
        volume: 0,
        fmRatio: 1,
        grainSize: 2,
        filterFreq: 3,
        pitchOffset: 4,
        
        // Second row CC numbers
        fmDepth: 32,
        grainDensity: 33,
        decayTime: 34,
        delayMix: 35,
        reverbMix: 36
    ),
    
    channel12: (
        playbackRate: 0,
        minGap: 1
    )
);

// MIDI responders
MIDIdef.cc(\volumeControl, {|val, num, chan, src|
    if(chan == 14 && num == ~midiControl.channel14.volume) {
        ~controlBuses[\volume].set(val.linlin(0, 127, 0, 1));
    };
});

MIDIdef.cc(\fmControl, {|val, num, chan, src|
    if(chan == 14 && num == ~midiControl.channel14.fmRatio) {
        ~controlBuses[\fmRatio].set(val.linlin(0, 127, 0.5, 4));
    };
});

MIDIdef.cc(\reverbControl, {|val, num, chan, src|
    if(chan == 14 && num == ~midiControl.channel14.reverbMix) {
        ~effectProcessor.set(\wetDry, val.linlin(0, 127, 0, 1));
    };
});

// Print available MIDI devices
"MIDI Sources:".postln;
MIDIClient.sources.do{|src| "\t%".format(src).postln };
"MIDI Destinations:".postln;
MIDIClient.destinations.do{|dst| "\t%".format(dst).postln };

// Print control mapping
"MIDI Control Map:".postln;
"Channel 14, First Row:".postln;
"  CC 0  -> Volume".postln;
"  CC 1  -> FM Ratio".postln;
"  CC 2  -> Grain Size".postln;
"  CC 3  -> Filter Freq".postln;
"  CC 4  -> Pitch Offset".postln;
"".postln;
"Channel 14, Second Row:".postln;
"  CC 32 -> FM Depth".postln;
"  CC 33 -> Grain Density".postln;
"  CC 34 -> Decay Time".postln;
"  CC 35 -> Delay Mix".postln;
"  CC 36 -> Reverb Mix".postln;
"".postln;
"Channel 12:".postln;
"  CC 0  -> Playback Rate".postln;
"  CC 1  -> Minimum Gap".postln;

"MIDI Control System loaded.".postln;
"Faderfox LC2 ready on channels 12 and 14.".postln;
)