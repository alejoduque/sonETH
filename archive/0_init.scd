// SuperCollider Ethereum Sonification - System Initialization
// Current Date and Time (UTC): 2025-03-01 22:36:00
// Current User's Login: alejoduque
// Initialization Sequence: 1 of 9
// Depends on: none
// Required by: all other components

(
// Global state initialization
~globalState = ~globalState ?? {
    (
        transactionCount: 0,
        lastValue: 0,
        lastHash: "",
        lastGasPrice: 0,
        hasTrendAnalysis: false
    )
};

// Initialize core system components
~components = (
    serverConfig: "1_server_config.scd",
    synthdefs: "2_synthdefs.scd",
    midi: "3_midi_control.scd",
    gui: "4_gui.scd",
    beatEngine: "5_beat_engine.scd",
    oscHandlers: "6_osc_handlers.scd",
    trendAnalysis: "7_trend_analysis.scd",
    transactionBuffer: "8_transaction_buffer.scd",
    spatialSim: "9_spatial_headphone_sim.scd"
);

// Initialize placeholder for trend analysis
~trendAnalysis = nil;

// Initialize audio parameters
~audioParams = (
    masterVolume: 0.5,
    transactionVolume: 0.3,
    beatVolume: 0.4
);

// Initialize visualization parameters
~visualParams = (
    refreshRate: 60,
    colorScheme: (
        background: Color.black,
        foreground: Color.green,
        accent: Color.blue
    )
);

"System Initialization complete.".postln;
)