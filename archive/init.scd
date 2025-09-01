// SuperCollider Ethereum Sonification - System Initialization
// Current Date and Time (UTC): 2025-03-01 04:32:05
// Current User's Login: alejoduque

// 1. Environment Setup
~mainDirectory = thisProcess.nowExecutingPath.dirname;
~projectName = "Ethereum Sonification";
~version = "2.0.0";

// 2. Server Configuration
Server.default.options.memSize = 8192 * 16;
Server.default.options.numBuffers = 1024 * 16;
Server.default.options.maxNodes = 1024 * 16;
Server.default.options.numAudioBusChannels = 128;
Server.default.options.numControlBusChannels = 4096;
Server.default.options.numInputBusChannels = 2;
Server.default.options.numOutputBusChannels = 2;
Server.default.options.memoryLocking = true;
Server.default.options.threads = 4;

// 3. Global Variables
~globalState = (
    isPlaying: false,
    midiInitialized: false,
    oscInitialized: false,
    lastTransactionTime: 0,
    transactionCount: 0,
    fadeTime: 0.5
);

// 4. Initialize Function
~init = {
    // Boot server
    Server.default.waitForBoot({
        // Create basic groups
        ~sourceGroup = Group.new;
        ~effectGroup = Group.after(~sourceGroup);

        // Initialize buses
        ~buses = ~buses ?? ();
        [
            \volume, \fmRatio, \fmDepth, \grainSize, \grainDensity,
            \filterFreq, \decay, \delayMix, \reverbMix, \pitchOffset,
            \bellTone, \bellRes, \bellSpread, \playbackRate
        ].do { |name|
            ~buses[name] = Bus.control(s, 1).set(1);
            ("Created bus: %".format(name)).postln;
        };

        // Initialize MIDI if not already done
        if(MIDIClient.initialized.not) {
            MIDIClient.init;
            MIDIIn.connectAll;
            ~globalState.midiInitialized = true;
        };

        // Clear any existing MIDI/OSC definitions
        MIDIdef.freeAll;
        OSCdef.freeAll;

        // Load required files
        [
            "main.scd",
            "3_synthdefs.scd",
            "2_midi_control.scd"
        ].do { |filename|
            var path = ~mainDirectory +/+ filename;
            if(File.exists(path)) {
                ("Loading " ++ filename ++ "...").postln;
                path.load;
            } {
                ("File not found: " ++ filename).warn;
            };
        };

        // Emergency cleanup function
        ~cleanup = {
            "Cleaning up...".postln;
            MIDIdef.freeAll;
            OSCdef.freeAll;
            ~buses.do(_.free);
            ~sourceGroup.free;
            ~effectGroup.free;
            "System cleaned up.".postln;
        };

        // Register shutdown hook
        ShutDown.add { ~cleanup.value };

        // System status report
        (
            "% v% Initialized:\n".format(~projectName, ~version) ++
            "- Server Status: %\n".format(Server.default.status) ++
            "- Memory: % MB\n".format(Server.default.options.memSize / 1024) ++
            "- MIDI Status: %\n".format(if(~globalState.midiInitialized, "Connected", "Not connected")) ++
            "- Control Buses: %\n".format(~buses.size) ++
            "- Faderfox LC2 Channels: 12, 14\n" ++
            "- OSC Port: 57120\n\n" ++
            "System ready for sonification."
        ).postln;
    });
};

// 5. Test Function
~test = {
    if(Server.default.serverRunning) {
        "Testing system...".postln;
        
        // Test sound
        Synth(\elektronBell, [
            \freq, 440,
            \amp, 0.3,
            \dec, 1.0
        ]);
        
        // Test MIDI
        "Move Faderfox LC2 encoders (channels 12 & 14) to control sound.".postln;
        "Channel 14 (CCs 32-38): Volume, Tone, Decay, Delay, Reverb, Filter, Pitch".postln;
        "Channel 12 (CCs 32-35): FM Depth, FM Ratio, Resonance, Spread".postln;
        
        // Test OSC
        "Send test transaction:".postln;
        "n = NetAddr(\"localhost\", 57120);".postln;
        "n.sendMsg(\"/tx\", \"0x123456789\", 0.5, 20);".postln;
    } {
        "Server not running. Run ~init.value; first.".warn;
    };
};

// 6. Error Handler
Error.debug = true;
Error.handler = { |error|
    ("ERROR: " ++ error.errorString).postln;
    error.reportError;
    "Attempting to continue...".postln;
};

// Welcome message
(
    "\n=== % v% ===\n".format(~projectName, ~version) ++
    "Current Date (UTC): %\n".format(Date.getDate.format("%Y-%m-%d %H:%M:%S")) ++
    "User: %\n\n".format(~mainDirectory.basename) ++
    "Run ~init.value; to start the system\n" ++
    "Run ~test.value; to test the system\n" ++
    "Run ~cleanup.value; for emergency cleanup"
).postln;

"Init file loaded. Run ~init.value; to start the system.".postln;