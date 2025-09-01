(
// Initialize MIDI system
MIDIClient.init;
MIDIIn.connectAll;

// Clear any existing responders to avoid duplicates
MIDIdef.freeAll;

// Create a metadata view in the post window
"=== MIDI CONTROLLER DIAGNOSTIC TOOL ===".postln;
"Current date/time: %".format(Date.getDate.format("%Y-%m-%d %H:%M:%S")).postln;

// List all available MIDI devices
"Available MIDI sources:".postln;
MIDIClient.sources.do { |src, i|
    "  [%] % (%)".format(i, src.device, src.name).postln;
};

"Available MIDI destinations:".postln;
MIDIClient.destinations.do { |dest, i|
    "  [%] % (%)".format(i, dest.device, dest.name).postln;
};

"=== MONITORING STARTED (Move controls on your device) ===".postln;

// 1. Monitor Control Change messages (knobs, sliders, faders)
MIDIdef.cc(\cc_monitor, { |val, num, chan, src|
    "CC: controller=% value=% channel=% source=% (%)".format(
        num, val, chan, MIDIClient.sources[src].device, Date.getDate.format("%H:%M:%S")
    ).postln;
}, nil, nil); // Listen to all CCs on all channels

// 2. Monitor Note On messages (keys, pads, buttons configured as notes)
MIDIdef.noteOn(\noteon_monitor, { |val, num, chan, src|
    "NOTE ON: note=% velocity=% channel=% source=% (%)".format(
        num, val, chan, MIDIClient.sources[src].device, Date.getDate.format("%H:%M:%S")
    ).postln;
}, nil, nil);

// 3. Monitor Note Off messages
MIDIdef.noteOff(\noteoff_monitor, { |val, num, chan, src|
    "NOTE OFF: note=% velocity=% channel=% source=% (%)".format(
        num, val, chan, MIDIClient.sources[src].device, Date.getDate.format("%H:%M:%S")
    ).postln;
}, nil, nil);

// 4. Monitor Pitch Bend messages (wheels, joysticks)
MIDIdef.bend(\bend_monitor, { |val, chan, src|
    "PITCH BEND: value=% channel=% source=% (%)".format(
        val, chan, MIDIClient.sources[src].device, Date.getDate.format("%H:%M:%S")
    ).postln;
}, nil);

// 5. Monitor Aftertouch (pressure sensitivity)
MIDIdef.touch(\aftertouch_monitor, { |val, chan, src|
    "AFTERTOUCH: value=% channel=% source=% (%)".format(
        val, chan, MIDIClient.sources[src].device, Date.getDate.format("%H:%M:%S")
    ).postln;
}, nil);

// 6. Monitor Poly Aftertouch (per-key pressure)
MIDIdef.polyTouch(\polytouch_monitor, { |val, note, chan, src|
    "POLY TOUCH: note=% value=% channel=% source=% (%)".format(
        note, val, chan, MIDIClient.sources[src].device, Date.getDate.format("%H:%M:%S")
    ).postln;
}, nil, nil);

// 7. Monitor Program Change messages
MIDIdef.program(\program_monitor, { |val, chan, src|
    "PROGRAM CHANGE: program=% channel=% source=% (%)".format(
        val, chan, MIDIClient.sources[src].device, Date.getDate.format("%H:%M:%S")
    ).postln;
}, nil);

// 8. Monitor System Exclusive messages
MIDIFunc.sysex({ |data, src|
    "SYSEX: data=[%, ...] (length=%) source=% (%)".format(
        data[0..min(10, data.size-1)], data.size, MIDIClient.sources[src].device, Date.getDate.format("%H:%M:%S")
    ).postln;
});

// 9. Monitor MIDI Clock messages
MIDIdef.midiClock(\clock_monitor, {
    "MIDI CLOCK received".postln;
});

// Function to stop monitoring
~stopMIDIMonitoring = {
    MIDIdef.freeAll;
    "=== MIDI MONITORING STOPPED ===".postln;
};

"To stop monitoring, run: ~stopMIDIMonitoring.value".postln;
)