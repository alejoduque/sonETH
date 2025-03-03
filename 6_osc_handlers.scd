// SuperCollider Ethereum Sonification - OSC Handlers
// Current Date and Time (UTC): 2025-03-02 05:14:08
// Current User's Login: alejoduque
// Initialization: 6/9

(
// Initialize OSC state
~oscState = (
    lastMessage: nil,
    messageCount: 0,
    startTime: SystemClock.seconds
);

// Transaction handler
~handleTransaction = { |msg|
    var value = msg[1].asFloat;
    var hash = msg[2].asString;
    
    ~oscState.lastMessage = msg;
    ~oscState.messageCount = ~oscState.messageCount + 1;
    
    if(~mainGroup.notNil) {
        Synth(\elektronBell, [
            \freq, value.linexp(0, 10, 200, 1000),
            \amp, value.linlin(0, 10, 0.1, 0.5) * ~audioParams.transactionVolume,
            \out, ~audioBuses.transactions
        ], ~mainGroup);
    };
    
    {
        ~valueDisplay !? {
            ~valueDisplay.string = "Last Value: % ETH".format(value.round(0.001))
        };
    }.defer;
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
    "Test transaction triggered.".postln;
};

// Print status
[
    "OSC Handlers initialized:",
    "- Listening on port: 57120",
    "- Transaction sonification ready",
    "- Use ~testTransaction.value; to test",
].join("\n").postln;
)