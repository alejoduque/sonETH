// SuperCollider Ethereum Sonification - Main Loader
// Current Date and Time (UTC): 2025-03-01 21:57:53
// Current User's Login: alejoduque

(
// Function to load all components
~loadEthereumSonification = {
    var basePath = thisProcess.nowExecutingPath.dirname;

    // Load components in order - critical server and synth components first
    [
        "0_server_config.scd",    // Server configuration
        "1_init.scd",             // Basic initialization
        "3_synthdefs.scd",        // MOVED UP - SynthDefs must load early
        "2_midi_control.scd",     // MIDI configuration
        "4_gui.scd",              // GUI components
        "5_beat_engine.scd",      // Beat engine
        "6_osc_handlers.scd",     // OSC handlers
        "7_trend_analysis.scd",   // Analysis tools
        "8_transaction_buffer.scd" // Transaction management
    ].do { |file|
        var path = basePath +/+ file;
        ("Loading " ++ file ++ "...").postln;
        if(File.exists(path)) {
            try {
                path.load;
                // Add timestamp after each successful load
                ("Loaded at: " ++ Date.getDate.format("%Y-%m-%d %H:%M:%S")).postln;
                0.5.wait; // Give each component time to initialize
            } { |error|
                ("Error loading " ++ file ++ ": " ++ error.errorString).error;
            };
        } {
            ("File not found: " ++ path).warn;
        };
    };

    // Clean up any existing resources
    s.freeAll; // Free all synths first
    if(~baseDrone.notNil) { ~baseDrone.free };
    if(~backgroundNoise.notNil) { ~backgroundNoise.free };
    if(~atmosphereDrones.notNil) { ~atmosphereDrones.do(_.free) };
    if(~beatWindow.notNil) { ~beatWindow.close };

    // Initialize the system
    s.waitForBoot {
        s.sync; // Wait for server sync
        
        // Verify SynthDef loaded
        if(SynthDescLib.global.synthDescs.at(\elektronBell).isNil) {
            "ERROR: elektronBell SynthDef not found! Check synthdefs.scd".error;
        } {
            "elektronBell SynthDef loaded successfully.".postln;
        };

        ~setupMidiControl.value;
        ~addBeatControls.value;
        ~beatEngine.value;

        // Initialize OSC reception
        "Setting up OSC reception...".postln;
        NetAddr.langPort.postln;

        // System status with timestamp
        (
            "Ethereum Sonification System loaded and running.\n" ++
            "Current time (UTC): " ++ Date.getDate.format("%Y-%m-%d %H:%M:%S") ++
            "\nListening for transactions on port: " ++ NetAddr.langPort
        ).postln;
        
        // Test sound after initialization
        Synth(\elektronBell, [\freq, 440, \amp, 0.3]);
    };
};

// Start the system
s.waitForBoot {
    ~loadEthereumSonification.value;
};
)

// Keep all your existing debugging tools below
/*
// 1. Check MIDI devices and connections
MIDIClient.init;
MIDIIn.connectAll;
... [rest of your debugging code remains unchanged]
*/