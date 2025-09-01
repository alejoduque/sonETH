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

        // Calculate frequency mapping first
        var baseFreq, noteNum, synthArgs;
        
        // Convert ETH value to MIDI note for better variation
        noteNum = value.linlin(0.001, 10, 24, 96).round(1);  // C1 to C7 range
        baseFreq = noteNum.midicps;  // Convert MIDI note to frequency
        
        // Add hash-based micro-variation for identical values
        baseFreq = baseFreq * (1 + (txHash.hash.fold(-0.05, 0.05)));

        // Update global state
        ~globalState.transactionCount = ~globalState.transactionCount + 1;
        ~globalState.lastValue = value;
        ~globalState.lastHash = txHash;
        ~globalState.lastGasPrice = gasPrice;

        // Debug output with note information
        (
            "\n=== TRANSACTION % ===".format(~globalState.transactionCount + 1).postln;
            "Hash: %".format(txHash[0..10]).postln;
            "Value: % ETH → Note: %, Freq: % Hz".format(value, noteNum, baseFreq.round(1)).postln;
            "Gas: % gwei".format(gasPrice).postln;
            "Active synths before: %".format(s.numSynths).postln;
        );

        // Create sound with MIDI bus connections for real-time control
        synthArgs = [
            \freq, baseFreq,
            \amp, 0.2,  // Reduced base amplitude for cleaner mix
            \dec, gasPrice.linlin(1, 200, 0.5, 4.0),  // Gas affects decay time (longer)
            \pan, txHash.hash.fold(-1.0, 1.0),
            \rel, value.linlin(0.001, 10, 1.0, 8.0)  // Transaction value affects release time
        ];
        
        // Add ALL bus connections - ensure every transaction synth gets real-time control
        if(~buses.notNil) {
            // Always connect ALL buses to each transaction synth
            ~buses.keysValuesDo { |paramName, bus|
                var busParamName = (paramName.asString ++ "Bus").asSymbol;
                synthArgs = synthArgs ++ [busParamName, bus.index];
                "Connecting % to bus index %".format(busParamName, bus.index).postln;
            };
        } {
            "WARNING: ~buses not available, using default values".warn;
        };
        
        // Create the transaction synth with all control connections
        "Creating elektronBell with % parameters".format(synthArgs.size / 2).postln;
        {
            var newSynth = Synth(\elektronBell, synthArgs);
            "New synth created: %".format(newSynth).postln;
            "Active synths after: %".format(s.numSynths).postln;
        }.value;

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
        if(~addTrendValue.notNil) {
            ~addTrendValue.value(value);
        };
    }, '/tx');

    "OSC Handlers initialized:".postln;
    "- Listening on port: %".format(NetAddr.langPort).postln;
    "- Transaction sonification ready".postln;
    "- Use ~testSound.value; to test audio".postln;
    "- Use ~startOSCMonitor.value; to debug OSC".postln;
});
)