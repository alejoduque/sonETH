// SuperCollider Ethereum Sonification - Main Loader
// Current Date and Time (UTC): 2025-03-01 22:59:03
// Current User's Login: alejoduque
// System Component Dependencies:
/*
Initialization Sequence:
1. 0_init.scd          - System initialization
2. 1_server_config.scd - Server setup
3. 2_synthdefs.scd     - Sound definitions
4. 3_midi_control.scd  - MIDI interface setup
5. 4_gui.scd           - GUI components
6. 5_beat_engine.scd   - Beat processing
7. 6_osc_handlers.scd  - OSC message handling
8. 7_trend_analysis.scd - Transaction trend analysis
9. 8_transaction_buffer.scd - Transaction management
*/

(
// Function to load all components
~loadEthereumSonification = Routine({
    var basePath = thisProcess.nowExecutingPath.dirname;
    var componentErrors = List[];
    
    // First, quit server if running
    if(Server.default.serverRunning) {
        "Stopping server...".postln;
        Server.default.quit;
        2.wait;
    };
    
    // Load initialization first
    "Loading system initialization...".postln;
    try {
        (basePath +/+ "0_init.scd").load;
        1.wait;
    } { |error|
        ("ERROR: Failed to load initialization - " ++ error.errorString).error;
        error.throw; // Critical error - stop loading
    };
    
    // Verify initialization
    if(~globalState.isNil or: {~components.isNil}) {
        Error("System initialization failed - global state or components not initialized!").throw;
    };
    
    // Component verification function
    ~verifyComponent = { |name|
        case
        { name == \serverConfig } {
            if(Server.default.serverRunning) {
                "✓ Server running.".postln;
                true
            } {
                "✗ Server not running.".error;
                false
            }
        }
        { name == \synthdefs } {
            if(SynthDescLib.global.synthDescs.at(\elektronBell).notNil) {
                "✓ SynthDefs loaded.".postln;
                true
            } {
                "✗ SynthDefs not loaded.".error;
                false
            }
        }
        { name == \midi } {
            if(MIDIClient.initialized) {
                "✓ MIDI initialized.".postln;
                true
            } {
                "✗ MIDI not initialized.".error;
                false
            }
        }
        { name == \gui } {
            if(~mainWindow.notNil) {
                "✓ GUI created.".postln;
                true
            } {
                "✗ GUI not created.".error;
                false
            }
        }
        { name == \beatEngine } {
            if(~beatEngine.notNil) {
                "✓ Beat engine loaded.".postln;
                true
            } {
                "✗ Beat engine not loaded.".error;
                false
            }
        }
        { name == \oscHandlers } {
            if(OSCdef(\txHandler).notNil) {
                "✓ OSC handlers configured.".postln;
                true
            } {
                "✗ OSC handlers not configured.".error;
                false
            }
        }
        { name == \trendAnalysis } {
            if(~trendAnalysis.notNil) {
                "✓ Trend analysis system loaded.".postln;
                true
            } {
                "✗ Trend analysis not loaded.".error;
                false
            }
        }
        { name == \transactionBuffer } {
            if(~transactionBuffer.notNil) {
                "✓ Transaction buffer loaded.".postln;
                true
            } {
                "✗ Transaction buffer not loaded.".error;
                false
            }
        }
        { true }; // Default case
    };
    
    // Load remaining components in sequence
    ~components.keysValuesDo({ |component, file|
        var path = basePath +/+ file;
        ("\nLoading % (%):".format(component, file)).postln;
        
        try {
            if(File.exists(path)) {
                path.load;
                ("Loaded at: " ++ Date.getDate.format("%Y-%m-%d %H:%M:%S")).postln;
                if(~verifyComponent.(component).not) {
                    componentErrors.add(component);
                };
                1.wait;
            } {
                ("WARNING: File not found - %".format(file)).warn;
                componentErrors.add(component);
            };
        } { |error|
            ("ERROR: Failed to load % - %".format(file, error.errorString)).error;
            componentErrors.add(component);
        };
    });
    
    // Final system verification
    2.wait;
    (
        "\nSystem Status:".postln;
        "==============".postln;
    );
    
    if(componentErrors.size > 0) {
        (
            "\nComponent Loading Errors:".postln;
            "- Failed components: %".format(componentErrors.join(", ")).error;
        );
    };
    
    if(~checkServerStatus.notNil) {
        ~checkServerStatus.value;
    };
    
    // System verification summary
    (
        "\nSystem Verification:".postln;
        "- Server Status: %".format(if(Server.default.serverRunning, "✓", "✗")).postln;
        "- SynthDefs Loaded: %".format(if(SynthDescLib.global.synthDescs.at(\elektronBell).notNil, "✓", "✗")).postln;
        "- MIDI Initialized: %".format(if(MIDIClient.initialized, "✓", "✗")).postln;
        "- GUI Active: %".format(if(~mainWindow.notNil, "✓", "✗")).postln;
        "- Beat Engine: %".format(if(~beatEngine.notNil, "✓", "✗")).postln;
        "- OSC Handlers: %".format(if(OSCdef(\txHandler).notNil, "✓", "✗")).postln;
        "- Trend Analysis: %".format(if(~trendAnalysis.notNil, "✓", "✗")).postln;
        "- Transaction Buffer: %".format(if(~transactionBuffer.notNil, "✓", "✗")).postln;
    );
    
    // Test system if everything loaded correctly
    if(componentErrors.size == 0) {
        "\nRunning system tests...".postln;
        
        // Test audio
        if(~testSound.notNil) {
            "Testing audio...".postln;
            ~testSound.value;
            1.wait;
        };
        
        // Test transaction processing
        if(~testTransaction.notNil) {
            "Testing transaction processing...".postln;
            ~testTransaction.value;
            1.wait;
        };
        
        // Start beat engine
        if(~beatEngine.notNil) {
            "Starting beat engine...".postln;
            ~beatEngine.start;
        };
        
        "System initialization and testing complete.".postln;
    } {
        "System initialization completed with errors. Check component status.".error;
    };
});

// Start the system
SystemClock.play(~loadEthereumSonification);
)