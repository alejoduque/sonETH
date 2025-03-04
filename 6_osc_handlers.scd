// SuperCollider Ethereum Sonification - OSC Handlers
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-03 22:51:45
// Current User's Login: alejoduque
// Initialization: 6/9

(
// Initialize OSC state
~oscState = (
    lastMessage: nil,
    messageCount: 0,
    startTime: SystemClock.seconds
);

// Initialize transaction counter if it doesn't exist
~transactionCounter = ~transactionCounter ?? { 0 };

// Transaction handler
~handleTransaction = { |msg|
    var value = msg[1].asFloat;
    var hash = msg[2].asString;
    
    ~oscState.lastMessage = msg;
    ~oscState.messageCount = ~oscState.messageCount + 1;
    ~transactionCounter = ~transactionCounter + 1;  // Update counter for GUI
    
    if(~mainGroup.notNil) {
        // Create synth with all control bus mappings
        Synth(\elektronBell, [
            \freq, value.linexp(0, 10, 200, 1000),
            \amp, value.linlin(0, 10, 0.1, 0.5) * ~audioParams.transactionVolume,
            \out, ~audioBuses.transactions,
            // Add all control bus mappings
            \volumeBus, ~controlBuses.volume,
            \fmRatioBus, ~controlBuses.fmratio,
            \grainSizeBus, ~controlBuses.grainsize,
            \filterFreqBus, ~controlBuses.filterfreq,
            \pitchOffsetBus, ~controlBuses.pitchoffset,
            \fmDepthBus, ~controlBuses.fmdepth,
            \grainDensityBus, ~controlBuses.graindensity,
            \decayBus, ~controlBuses.decay,
            \delayMixBus, ~controlBuses.delaymix,
            \reverbMixBus, ~controlBuses.reverbmix
        ], ~mainGroup);
        
        // Update trend analysis if available
        ~trendAnalysis !? {
            ~trendAnalysis.addValue(value);
        };
    };
    
    // Update GUI elements
    {
        ~valueDisplay !? {
            ~valueDisplay.string = "Last Value: % ETH".format(value.round(0.001))
        };
        
        // Update last transaction info in GUI if available
        if(~gui.notNil) {
            ~gui.lastTxInfo = "TX: % (% ETH)".format(
                hash[0..7],  // Show first 8 characters of hash
                value.round(0.001)
            );
        };
    }.defer;
};

// OSC definition for transactions
OSCdef(\transactionHandler, { |msg, time, addr, port|
    ~handleTransaction.value(msg);
}, '/eth/transaction');

// Add OSC definition for control messages
OSCdef(\controlHandler, { |msg, time, addr, port|
    var control = msg[1].asSymbol;
    var value = msg[2].asFloat;
    
    // Update appropriate control bus if it exists
    ~controlBuses[control] !? { |bus|
        bus.set(value);
        ~controlValues[control] = value;
        "Control %: %".format(control, value).postln;
    };
}, '/eth/control');

// Test function for transactions
~testTransaction = {
    ~handleTransaction.value([
        '/eth/transaction',
        1.5,  // value in ETH
        "0x123test",  // hash
        SystemClock.seconds  // timestamp
    ]);
    "Test transaction triggered.".postln;
};

// Test function for controls
~testControl = { |control, value|
    OSCdef(\controlHandler).value([
        '/eth/control',
        control,
        value
    ], SystemClock.seconds, nil, 57120);
    "Test control: % -> %".format(control, value).postln;
};

// Print status
[
    "OSC Handlers initialized:",
    "- Listening on port: 57120",
    "- Transaction sonification ready",
    "- Control messages enabled",
    "- Use ~testTransaction.value; to test transactions",
    "- Use ~testControl.value(\\control, value); to test controls",
].join("\n").postln;
)