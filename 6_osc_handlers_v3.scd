// SuperCollider Ethereum Sonification - OSC Handlers
// Current Date and Time (UTC): 2025-03-01 22:26:45
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

// Create default group if not exists
s.waitForBoot({
    if(Group.basicNew(s, 1).isPlaying.not) {
        Group(s, \addToHead);
    };
    
    // Free any existing OSC definitions to prevent duplicates
    OSCdef(\txHandler).free;

    // Create OSC handler for transactions
    OSCdef(\txHandler, {|msg, time, addr, port|
        var txHash = msg[1].asString;
        var value = msg[2].asFloat;
        var gasPrice = msg[3].asFloat;

        // Update global state
        ~globalState.transactionCount = ~globalState.transactionCount + 1;
        ~globalState.lastValue = value;
        ~globalState.lastHash = txHash;
        ~globalState.lastGasPrice = gasPrice;

        // Debug output
        (
            "\nTransaction Received:".postln;
            "Hash: %".format(txHash).postln;
            "Value: % ETH".format(value).postln;
            "Gas: % gwei".format(gasPrice).postln;
        );

        // Create sound
        Synth(\elektronBell, [
            \freq, value.linexp(0.001, 10, 200, 800),
            \amp, value.linlin(0.001, 10, 0.2, 0.5),
            \dec, gasPrice.linlin(1, 100, 0.5, 2.0),
            \pan, txHash.hash.fold(-1.0, 1.0)
        ]);

        // Update GUI if available
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

        // Update trend analysis
        if(~trendAnalysis.notNil) {
            ~trendAnalysis.add(value);
        };
    }, '/tx');

    "OSC Handlers initialized:".postln;
    "- Listening on port: %".format(NetAddr.langPort).postln;
    "- Transaction sonification ready".postln;
    "- Use ~testSound.value; to test audio".postln;
    "- Use ~startOSCMonitor.value; to debug OSC".postln;
});
)