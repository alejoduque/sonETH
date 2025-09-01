// SuperCollider Ethereum Sonification - OSC Handlers
// Current Date and Time (UTC): 2025-03-01 05:23:28
// Current User's Login: alejoduque

(
// Clear any existing OSC definitions
OSCdef.freeAll;

// Ensure server is booted
Server.default.waitForBoot({
    
    // Initialize default parameters if not already set
    ~beatParams = ~beatParams ?? (
        masterAmp: 0.7,
        beatTempo: 1.0,
        droneFade: 2.0,
        droneSpace: 0.5
    );

    // Transaction handler
    OSCdef(\txHandler, { |msg, time, addr, port|
        var txHash = msg[1].asString;
        var value = msg[2].asFloat;
        var gasPrice = msg[3].asFloat;
        
        // Update transaction count
        ~globalState.transactionCount = ~globalState.transactionCount + 1;
        ~globalState.lastTransactionTime = time;
        
        // Ensure synth is loaded
        if(SynthDescLib.global.synthDescs.at(\elektronBell).notNil) {
            // Create sound with debugging
            "Creating sound for transaction...".postln;
            Synth(\elektronBell, [
                \freq, value.linexp(0.001, 10, 200, 800),
                \amp, value.linlin(0.001, 10, 0.2, 0.5) * (~beatParams.masterAmp ? 0.7),
                \dec, gasPrice.linlin(1, 100, 0.5, 2.0),
                \pan, txHash.hash.fold(-1.0, 1.0)
            ]);
            "Sound created.".postln;
        } {
            "ERROR: SynthDef elektronBell not found!".postln;
        };
        
        // Log transaction
        ("Received TX: % | % ETH | % gwei".format(
            txHash[0..9],
            value.round(0.001),
            gasPrice.round(0.001)
        )).postln;
        
    }, '/tx');

    // Test function to verify sound
    ~testSound = {
        if(SynthDescLib.global.synthDescs.at(\elektronBell).notNil) {
            "Testing sound...".postln;
            Synth(\elektronBell, [
                \freq, 440,
                \amp, 0.5,
                \dec, 1.0,
                \pan, 0
            ]);
            "Test sound created.".postln;
        } {
            "ERROR: SynthDef elektronBell not found!".postln;
        };
    };

    "OSC Handlers initialized and ready for transactions.".postln;
    "Listening on port: %".format(NetAddr.langPort).postln;
    "Use ~testSound.value; to test audio output".postln;
});
)