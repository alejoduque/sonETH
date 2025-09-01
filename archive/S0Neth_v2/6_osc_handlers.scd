// SuperCollider Ethereum Sonification - OSC Handlers
// Current Date and Time (UTC): 2025-03-02 01:07:52
// Current User's Login: alejoduque
// Initialization Sequence: 7 of 9

(
try {
    // Initialize state
    ~oscState = (
        lastMessage: nil,
        messageCount: 0,
        startTime: SystemClock.seconds,
        active: false
    );
    
    // Transaction handler
    ~handleTransaction = { |msg|
        try {
            var value = msg[1].asFloat;
            var hash = msg[2].asString;
            var timestamp = msg[3] ? SystemClock.seconds;
            
            ~oscState.lastMessage = msg;
            ~oscState.messageCount = ~oscState.messageCount + 1;
            
            if(s.serverRunning && ~mainGroup.notNil) {
                Synth(\elektronBell, [
                    \freq, value.linexp(0, 10, 200, 1000),
                    \amp, value.linlin(0, 10, 0.1, 0.5) * 
                        (~audioParams !? {~audioParams.transactionVolume} ? 0.3),
                    \out, ~audioBuses !? {~audioBuses.transactions} ? 0
                ], ~mainGroup);
            };
            
            ~trendAnalysis !? {
                ~trendAnalysis.use { ~add.value(value, timestamp) };
            };
            
            {
                ~valueDisplay !? {
                    ~valueDisplay.string = "Last Value: % ETH".format(
                        value.round(0.001)
                    );
                };
                ~activityMeter !? { ~activityMeter.refresh };
            }.defer;
            
        } { |err|
            "Transaction handler error: %".format(err.asString).error;
        };
    };
    
    // OSC definition
    OSCdef(\transactionHandler, { |msg, time, addr, port|
        ~handleTransaction.value(msg);
    }, '/eth/transaction');
    
    // Test function
    ~testTransaction = {
        ~handleTransaction.value([
            '/eth/transaction',
            1.5,
            "0x123test",
            SystemClock.seconds
        ]);
    };
    
    [
        "OSC Handlers initialized:",
        "- Listening on port: 57120",
        "- Transaction sonification ready",
        "- Use ~testTransaction.value; to test",
    ].join("\n").postln;
    
} { |err|
    "OSC initialization error: %".format(err.asString).error;
};
)