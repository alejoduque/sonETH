// SuperCollider Ethereum Sonification - Initialization
// Current Date and Time (UTC): 2025-03-01 22:30:46
// Current User's Login: alejoduque

(
// Global state initialization
~globalState = ~globalState ?? {
    (
        transactionCount: 0,
        lastValue: 0,
        lastHash: "",
        lastGasPrice: 0,
        hasTrendAnalysis: false  // Add flag for trend analysis
    )
};

// Initialize trend analysis placeholder
// Will be fully configured when 7_trend_analysis.scd loads
~trendAnalysis = nil;

"Initialization complete.".postln;
)