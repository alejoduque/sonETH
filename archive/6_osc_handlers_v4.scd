// SuperCollider Ethereum Sonification - OSC Handlers
// Current Date and Time (UTC): 2025-03-01 22:07:22
// Current User's Login: alejoduque

(
// Initialize global state if not already done
~globalState = ~globalState ?? {
    (
        transactionCount: 0,
        lastValue: 0,
        lastHash: "",
        lastGasPrice: 0
    )
};

// Free any existing OSC definitions to prevent duplicates
OSCdef(\txHandler).free;

// Create OSC handler for transactions
OSCdef(\txHandler, {|msg, time, addr, port|
    var txHash = msg[1].asString;
    var value = msg[2].asFloat;
    var gasPrice = msg[3].asFloat;

    // Debug output
    (
        "\nTransaction Received:".postln;
        "Hash: %".format(txHash).postln;
        "Value: % ETH".format(value).postln;
        "Gas: % gwei".format(gasPrice).postln;
    );

    // Update global state
    ~globalState.transactionCount = ~globalState.transactionCount + 1;
    ~globalState.lastValue = value;
    ~globalState.lastHash = txHash;
    ~globalState.lastGasPrice = gasPrice;

    // Create sound
    try {
        Synth(\elektronBell, [
            \freq, value.linexp(0.001, 10, 200, 800),
            \amp, value.linlin(0.001, 10, 0.2, 0.5) * ~beatParams.masterAmp,
            \dec, gasPrice.linlin(1, 100, 0.5, 2.0),
            \pan, txHash.hash.fold(-1.0, 1.0)
        ]);

        // Update GUI if it exists
        {
            if(~transactionCount.notNil) {
                ~transactionCount.string = "Transactions: %".format(~globalState.transactionCount);
            };
            if(~valueDisplay.notNil) {
                ~valueDisplay.string = "Last Value: % ETH".format(value.round(0.001));
            };
            if(~activityMeter.notNil) {
                ~activityMeter.refresh;
            };
        }.defer;

    } { |error|
        ("Error creating synth: " ++ error.errorString).error;
    };
}, '/tx');

// Add OSC monitor for debugging
~startOSCMonitor = {
    "OSC Monitor enabled - watching for transaction messages...".postln;
    OSCFunc.trace(true);
};

~stopOSCMonitor = {
    "OSC Monitor disabled".postln;
    OSCFunc.trace(false);
};

// Test function
~testTransaction = {
    var testAddr = NetAddr("localhost", 57120);
    "Sending test transaction...".postln;
    testAddr.sendMsg("/tx", "0xtest", 1.5, 25);
};

"OSC Handlers initialized:".postln;
"- Listening on port: %".format(NetAddr.langPort).postln;
"- Transaction sonification ready".postln;
"- Use ~testSound.value; to test audio".postln;
"- Use ~startOSCMonitor.value; to debug OSC".postln;
)

// Uncomment to test:
// ~testTransaction.value;
// ~startOSCMonitor.value;