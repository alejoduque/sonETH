// SuperCollider Ethereum Sonification - Main Loader
// Current Date and Time (UTC): 2025-03-01 05:04:34
// Current User's Login: alejoduque

(
// Function to load all components
~loadEthereumSonification = {
    var basePath = thisProcess.nowExecutingPath.dirname;
    
    // Load components in order
    [
        "1_init.scd",
        "2_midi_control.scd",
        "3_synthdefs.scd",
        "4_gui.scd",
        "5_beat_engine.scd",
        "6_osc_handlers.scd",
        "7_trend_analysis.scd",
        "8_transaction_buffer.scd"
    ].do { |file|
        var path = basePath +/+ file;
        ("Loading " ++ file ++ "...").postln;
        if(File.exists(path)) {
            path.load;
            // Add timestamp after each successful load
            ("Loaded at: " ++ Date.getDate.format("%Y-%m-%d %H:%M:%S")).postln;
        } {
            ("File not found: " ++ path).warn;
        };
    };

    // Clean up any existing resources
    if(~baseDrone.notNil) { ~baseDrone.free };
    if(~backgroundNoise.notNil) { ~backgroundNoise.free };
    if(~atmosphereDrones.notNil) { ~atmosphereDrones.do(_.free) };
    if(~beatWindow.notNil) { ~beatWindow.close };

    // Initialize the system
    s.waitForBoot {
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
    };
};

// Start the system
s.waitForBoot {
    ~loadEthereumSonification.value;
};
)