// SuperCollider Ethereum Sonification - Main Loader
// Current Date and Time (UTC): 2025-03-01 22:23:45
// Current User's Login: alejoduque

(
// Function to load all components
~loadEthereumSonification = Routine({
    var basePath = thisProcess.nowExecutingPath.dirname;
    
    // First, quit server if running
    if(Server.default.serverRunning) {
        "Stopping server...".postln;
        Server.default.quit;
        2.wait;
    };
    
    // Load components in sequence
    [
        "0_server_config.scd",    // Server config first
        "1_init.scd",            // Basic initialization
        "2_midi_control.scd",    // MIDI setup
        "3_synthdefs.scd",       // Additional SynthDefs
        "4_gui.scd",             // GUI components
        "5_beat_engine.scd",     // Beat engine
        "6_osc_handlers.scd",    // OSC handlers
        "7_trend_analysis.scd",  // Analysis
        "8_transaction_buffer.scd", // Transaction management
        "9_spatial_headphone_sim.scd" // 4-channel headphone simulation
    ].do { |file|
        var path = basePath +/+ file;
        ("Loading " ++ file ++ "...").postln;
        
        try {
            if(File.exists(path)) {
                path.load;
                ("Loaded at: " ++ Date.getDate.format("%Y-%m-%d %H:%M:%S")).postln;
                1.wait; // Give each file time to initialize
            } {
                ("File not found: " ++ path).warn;
            };
        } { |error|
            ("Error loading " ++ file ++ ": " ++ error.errorString).error;
        };
    };
    
    // Final system check
    2.wait;
    if(~checkServerStatus.notNil) {
        ~checkServerStatus.value;
    };
    
    if(~testTransaction.notNil) {
        "Testing transaction system...".postln;
        ~testTransaction.value;
    };
    
    // Launch Python Ethereum data fetcher
    "".postln;
    "=== Python Ethereum Data Fetcher Setup ===".postln;
    "To start receiving live Ethereum transaction data:".postln;
    "".postln;
    "1. Open Terminal and navigate to project directory:".postln;
    ("   cd \"" ++ basePath.dirname.dirname ++ "\"").postln;
    "".postln;
    "2. Activate Python virtual environment:".postln;
    "   source venv/bin/activate".postln;
    "".postln;
    "3. Run the Ethereum data fetcher:".postln;
    "   python eth_sonification/eth_sonify.py".postln;
    "".postln;
    "=== Spatial Audio Setup ===".postln;
    "For headphone development (simulates 4-channel monitors):".postln;
    "   ~setSpatialMode.(\\headphones);".postln;
    "".postln;
    "For direct 4-channel monitor output:".postln;
    "   ~setSpatialMode.(\\quad);".postln;
    "".postln;
    "Test spatial positioning:".postln;
    "   ~testSpatial.value;".postln;
    "".postln;
    "The Python script will send OSC messages to this SuperCollider system.".postln;
    "==========================================".postln;
});

// Start the system
SystemClock.play(~loadEthereumSonification);
)