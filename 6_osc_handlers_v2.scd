// SuperCollider Ethereum Sonification - OSC Handlers
// Current Date and Time (UTC): 2025-03-01 21:32:21
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
        droneSpace: 0.5,
        filterCutoff: 1000,
        droneDepth: 0.5,
        droneRes: 0.3
    );

    // Enhanced Transaction handler
    OSCdef(\txHandler, { |msg, time, addr, port|
        var txHash = msg[1].asString;
        var value = msg[2].asFloat;
        var gasPrice = msg[3].asFloat;
        
        // Update transaction count and timing
        ~globalState.transactionCount = ~globalState.transactionCount + 1;
        ~globalState.lastTransactionTime = time;
        
        // Ensure synth is loaded
        if(SynthDescLib.global.synthDescs.at(\elektronBell).notNil) {
            var params;
            
            // Enhanced parameter mapping
            params = (
                // Basic parameters
                freq: value.linexp(0.001, 10, 100, 2000),    // Wider frequency range
                amp: value.linlin(0.001, 10, 0.2, 0.8) * (~beatParams.masterAmp ? 0.7),
                
                // Time parameters
                atk: gasPrice.linlin(1, 100, 0.001, 0.1),    // Attack based on gas
                dec: gasPrice.linlin(1, 100, 0.1, 2.0),      // Decay based on gas
                rel: value.linlin(0.001, 10, 0.2, 1.0),      // Release based on value
                
                // Timbral parameters
                tone: txHash.hash.fold(0.0, 1.0),            // Tone from hash
                res: gasPrice.linlin(1, 100, 0.2, 0.8),      // Resonance from gas
                pan: txHash.hash.fold(-1.0, 1.0)             // Pan from hash
            );
            
            // Update control buses if they exist
            if(~buses.notNil) {
                ~buses[\fmRatio].set(value.linlin(0.001, 5, 0.5, 4.0));      // FM ratio from value
                ~buses[\fmDepth].set(gasPrice.linlin(1, 50, 0.1, 0.8));      // FM depth from gas
                ~buses[\grainSize].set(value.linexp(0.001, 10, 0.05, 0.2));  // Grain size from value
                ~buses[\grainDensity].set(gasPrice.linlin(1, 100, 5, 40));   // Density from gas
                ~buses[\filterFreq].set(value.linexp(0.001, 10, 500, 5000)); // Filter from value
                ~buses[\delayMix].set(value.linlin(0.001, 10, 0.1, 0.6));    // Delay from value
                ~buses[\reverbMix].set(value.linlin(0.001, 10, 0.2, 0.7));   // Reverb from value
                ~buses[\pitchOffset].set(value.linlin(0.001, 10, -12, 12));  // Pitch from value
            };
            
            // Create sound
            "Creating sound for transaction...".postln;
            Synth(\elektronBell, params);
            
            // Update beat parameters
            ~beatParams.beatTempo = value.linexp(0.001, 5, 0.5, 2.0);
            ~beatParams.droneFade = gasPrice.linlin(1, 50, 0.5, 4.0);
            ~beatParams.droneSpace = params.pan;
            ~beatParams.filterCutoff = value.linexp(0.001, 10, 200, 2000);
            
            // Debug output
            (
                "Transaction Sonified:\n" ++
                "Hash: %\n".format(txHash[0..9]) ++
                "Value: % ETH\n".format(value.round(0.001)) ++
                "Gas: % gwei\n".format(gasPrice.round(0.001)) ++
                "Freq: % Hz\n".format(params.freq.round(1)) ++
                "Tempo: %\n".format(~beatParams.beatTempo.round(0.01))
            ).postln;
            
        } {
            "ERROR: SynthDef elektronBell not found!".postln;
        };
        
        // Update GUI if it exists
        if(~addTransaction.notNil) {
            {~addTransaction.value(value)}.defer;
        };
        
    }, '/tx');

    // Test function with enhanced parameters
    ~testSound = {
        if(SynthDescLib.global.synthDescs.at(\elektronBell).notNil) {
            "Testing sound...".postln;
            Synth(\elektronBell, [
                \freq, 440,
                \amp, 0.5 * (~beatParams.masterAmp ? 0.7),
                \atk, 0.01,
                \dec, 1.0,
                \rel, 0.5,
                \tone, 0.3,
                \res, 0.4,
                \pan, 0
            ]);
            "Test sound created.".postln;
        } {
            "ERROR: SynthDef elektronBell not found!".postln;
        };
    };

    // Print initialization status
    (
        "OSC Handlers initialized:\n" ++
        "- Listening on port: %\n".format(NetAddr.langPort) ++
        "- Transaction sonification ready\n" ++
        "- Use ~testSound.value; to test audio\n" ++
        "- MIDI controls active\n" ++
        "- GUI updates enabled"
    ).postln;
});
)