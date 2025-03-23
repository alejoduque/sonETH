// SuperCollider Ethereum Sonification - OSC Handlers
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-06 03:01:35
// Current User's Login: alejoduque

(
// Initialize OSC state
~oscState = (
    lastMessage: nil,
    messageCount: 0,
    startTime: SystemClock.seconds
);

// Initialize transaction counter if it doesn't exist
~transactionCounter = ~transactionCounter ?? { 0 };
~noteCounter = ~noteCounter ?? { 0 };

// Note handler (for sound)
~handleNote = { |msg|
    var note = msg[1].asInteger;
    var velocity = msg[2].asInteger;
    var instrument = msg[3].asInteger;
    var duration = msg[4].asFloat;
    
    ~noteCounter = ~noteCounter + 1;
    
    if(~mainGroup.notNil) {
        Synth(\elektronBell, [
            \out, ~audioBuses.transactions,
            \freq, note.midicps,
            \amp, velocity.linlin(0, 127, 0.1, 0.5),
            \att, 0.01,
            \dec, duration * 0.5,
            \rel, duration * 0.5,
            // MIDI control mappings
            \volumeBus, ~controlBuses.volume,      // CC 7
            \fmRatioBus, ~controlBuses.fmratio,   // CC 16
            \fmDepthBus, ~controlBuses.fmdepth,   // CC 17
            \filterFreqBus, ~controlBuses.filterfreq // CC 74
        ], ~mainGroup);
    };
    
    {
        if(~counters.notNil and: { ~counters.notes.notNil }) {
            ~counters.notes.string = ~noteCounter.asString;
        };
    }.defer;
};

// Transaction info handler (for display)
~handleTxInfo = { |msg|
    var txHash = msg[1].asString;
    var value = msg[2].asFloat;
    var gasPrice = msg[3].asFloat;
    var recipient = msg[4].asString;
    
    ~transactionCounter = ~transactionCounter + 1;
    
    // Update transaction density for beat engine
    ~beatParams.transactionDensity = (~transactionCounter / (SystemClock.seconds - ~oscState.startTime)).clip(0, 1);
    ~beatParams.lastTransactionTime = SystemClock.seconds;
    
    {
        if(~counters.notNil and: { ~counters.trans.notNil }) {
            ~counters.trans.string = ~transactionCounter.asString;
        };
        
        // Update transaction display if it exists
        if(~valueDisplay.notNil) {
            ~valueDisplay.string = "TX: % (% ETH, % gwei)"
                .format(txHash[0..7], value.round(0.001), gasPrice.round(0.1));
        };
    }.defer;
};

// OSC definitions
OSCdef(\note, { |msg, time, addr, port|
    ~handleNote.value(msg);
}, '/eth/note');

OSCdef(\txInfo, { |msg, time, addr, port|
    ~handleTxInfo.value(msg);
}, '/eth/tx_info');

// Start decay routine for transaction density
~decayRoutine.stop if: ~decayRoutine.notNil;
~decayRoutine = Routine {
    loop {
        if((SystemClock.seconds - ~beatParams.lastTransactionTime) > 5.0) {
            ~beatParams.transactionDensity = ~beatParams.transactionDensity * 0.95;
        };
        0.5.wait;
    };
}.play;

// Register cleanup
ServerQuit.add({ 
    OSCdef(\note).free;
    OSCdef(\txInfo).free;
    ~decayRoutine.stop;
});

[
    "OSC Handlers initialized:",
    "- Listening for notes on /eth/note",
    "- Listening for transaction info on /eth/tx_info",
    "- Transaction counter: %".format(~transactionCounter),
    "- Note counter: %".format(~noteCounter),
    "- Using MIDI controls for sound parameters"
].join("\n").postln;
)