// SuperCollider Ethereum Sonification - Main Loader
// Current Date and Time (UTC): 2025-03-01 19:37:41
// Current User's Login: alejoduque

(
// Function to load all components
~loadEthereumSonification = {
    var basePath = thisProcess.nowExecutingPath.dirname;

    // Load components in order - including 0_server_config
    [
        "0_server_config.scd",  // Added server config first
        "1_init.scd",
        "2_midi_control.scd",
        "3_synthdefs.scd",
        "4_gui.scd",
        "5_beat_engine.scd",
        "6_osc_handlers.scd",
        "7_trend_analysis.scd",
        "8_transaction_buffer.scd"
    ].do { |file|
        var path = basePath +/+ file;
        ("Loading " ++ file ++ "...").postln;
        if(File.exists(path)) {
            path.load;
            // Add timestamp after each successful load
            ("Loaded at: " ++ Date.getDate.format("%Y-%m-%d %H:%M:%S")).postln;
        } {
            ("File not found: " ++ path).warn;
        };
    };

    // Clean up any existing resources
    if(~baseDrone.notNil) { ~baseDrone.free };
    if(~backgroundNoise.notNil) { ~backgroundNoise.free };
    if(~atmosphereDrones.notNil) { ~atmosphereDrones.do(_.free) };
    if(~beatWindow.notNil) { ~beatWindow.close };

    // Initialize the system
    s.waitForBoot {
        ~setupMidiControl.value;
        ~addBeatControls.value;
        ~beatEngine.value;

        // Initialize OSC reception
        "Setting up OSC reception...".postln;
        NetAddr.langPort.postln;

        // System status with timestamp
        (
            "Ethereum Sonification System loaded and running.\n" ++
            "Current time (UTC): " ++ Date.getDate.format("%Y-%m-%d %H:%M:%S") ++
            "\nListening for transactions on port: " ++ NetAddr.langPort
        ).postln;
    };
};

// Start the system
s.waitForBoot {
    ~loadEthereumSonification.value;
};
)

/*// 1. Check MIDI devices and connections
MIDIClient.init;
MIDIIn.connectAll;
MIDIClient.sources;    // Should show your Faderfox LC2
MIDIClient.destinations;

// 2. Check if our buses are properly initialized
~buses.keys;           // Should show all our control buses
~controlBuses.keys;    // Should show all our parameter buses

// 3. Check SynthDef availability
SynthDescLib.global.synthDescs.keys; // Should show 'elektronBell' and others

// 4. Test sound generation directly in the current system
~testSound.value;      // Test the main synth

// 5. Check MIDI responders
MIDIdef.all;          // Should show our Faderfox LC2 controls

// 6. Check OSC status
NetAddr.langPort;      // Should match our OSC port (57120)
OSCdef.all;           // Should show our transaction handlers

// Check beat engine status
~beatParams.keys;      // Should show our parameters
~beatRoutine.isPlaying; // Should tell us if beat engine is running*/


//
// (
// "System Status:".postln;
// "Master Amp: %".format(~beatParams.masterAmp).postln;
// "Server Volume: %".format(s.volume.volume).postln;
// "Beat Tempo: %".format(~beatParams.beatTempo).postln;
// "Synth Count: %".format(Server.default.numSynths).postln;
// )
//
// OSCFunc.trace(true);
// OSCFunc.trace(false);
//
//
// ~checkMIDI = {
// 	MIDIFunc.cc({ |val, num, chan, src|
// 		"MIDI received: val: % num: % chan: %".format(val, num, chan).postln;
// 	});
// 	"MIDI monitoring enabled.".postln;
// };
// ~checkMIDI.value;
//

//
//
// // 1. Reset volume and verify
// s.volume = 0.dbamp;   // Set to 0 dB
// s.volume.volume.postln; // Should not be 0
//
// // 2. Check transaction handler
// (
// // Temporary debug version of transaction handler
// OSCdef(\txHandler).free; // Remove existing handler
//
// OSCdef(\txHandler, { |msg, time, addr, port|
// 	var txHash = msg[1].asString;
// 	var value = msg[2].asFloat;
// 	var gasPrice = msg[3].asFloat;
//
// 	// Debug output
// 	"Transaction received:".postln;
// 	"Hash: %".format(txHash).postln;
// 	"Value: % ETH".format(value).postln;
// 	"Gas: % gwei".format(gasPrice).postln;
//
// 	// Create sound with debug
// 	try {
// 		"Creating synth...".postln;
// 		"Master Amp: %".format(~beatParams.masterAmp).postln;
//
// 		Synth(\elektronBell, [
// 			\freq, value.linexp(0.001, 10, 200, 800),
// 			\amp, value.linlin(0.001, 10, 0.2, 0.5) * ~beatParams.masterAmp,
// 			\dec, gasPrice.linlin(1, 100, 0.5, 2.0),
// 			\pan, txHash.hash.fold(-1.0, 1.0)
// 		]);
//
// 		// Update GUI if it exists
// 		if(~addTransaction.notNil) {
// 			{
// 				"Updating GUI...".postln;
// 				~addTransaction.value(value);
// 			}.defer;
// 		} {
// 			"GUI update function not found!".postln;
// 		};
//
// 	} { |error|
// 		("Error creating synth: " ++ error.errorString).postln;
// 	};
// });
//
// // Test the handler
// n = NetAddr("localhost", 57120);
// n.sendMsg("/tx", "0xtest", 1.5, 25);
// )
//
// // 3. Check GUI functions
// (
// "GUI Functions:".postln;
// "addTransaction exists: %".format(~addTransaction.notNil).postln;
// "mainWindow exists: %".format(~mainWindow.notNil).postln;
// "visualizer exists: %".format(~visualizer.notNil).postln;
// "transactions array exists: %".format(~transactions.notNil).postln;
// )
//
//
//
//
//
//
//


//
//
//
//
//
// // 1. Test GUI updates directly
// (
// "Testing GUI update...".postln;
// {
// 	~addTransaction.value(1.5);
// 	~transactionCount.string = "Transactions: %".format(~globalState.transactionCount + 1);
// 	~valueDisplay.string = "Last Value: 1.5 ETH";
// }.defer;
// )
//
// // 2. Test sound generation with volume check
// (
// "Testing sound chain...".postln;
// s.volume = 0.dbamp;  // Reset to 0 dB
// ~beatParams.masterAmp = 0.7; // Reset master amplitude
//
// // Create test sound
// Synth(\elektronBell, [
// 	\freq, 440,
// 	\amp, 0.3,
// 	\dec, 0.5,
// 	\pan, 0
// ]);
//
// "Current volume settings:".postln;
// "Server volume: %".format(s.volume.volume).postln;
// "Master amp: %".format(~beatParams.masterAmp).postln;
// )
//
// // 3. Test OSC reception with full debug
// (
// OSCdef(\txHandler).free;
//
// OSCdef(\txHandler, { |msg, time, addr, port|
// 	var txHash = msg[1].asString;
// 	var value = msg[2].asFloat;
// 	var gasPrice = msg[3].asFloat;
//
// 	// Detailed debug output
// 	(
// 		"\nTransaction Received at %:\n".format(Date.getDate.format("%H:%M:%S")) ++
// 		"Hash: %\n".format(txHash) ++
// 		"Value: % ETH\n".format(value) ++
// 		"Gas: % gwei\n".format(gasPrice) ++
// 		"Server Status:\n" ++
// 		"- Running: %\n".format(s.serverRunning) ++
// 		"- Volume: %\n".format(s.volume.volume) ++
// 		"- Master Amp: %\n".format(~beatParams.masterAmp)
// 	).postln;
//
// 	// Create sound
// 	Synth(\elektronBell, [
// 		\freq, value.linexp(0.001, 10, 200, 800),
// 		\amp, value.linlin(0.001, 10, 0.2, 0.5) * ~beatParams.masterAmp,
// 		\dec, gasPrice.linlin(1, 100, 0.5, 2.0),
// 		\pan, txHash.hash.fold(-1.0, 1.0)
// 	]);
//
// 	// Update GUI
// 	{
// 		~addTransaction.value(value);
// 		~transactionCount.string = "Transactions: %".format(~globalState.transactionCount);
// 		~valueDisplay.string = "Last Value: % ETH".format(value.round(0.001));
// 	}.defer;
// }, '/tx');
//
// "OSC Handler updated with debug output.".postln;
// )
//
// // 4. Test MIDI control with visual feedback
// (
// MIDIdef(\lc2Ch14).free;
//
// MIDIdef.cc(\lc2Ch14, { |val, num, chan, src|
// 	var scaled = val.linlin(0, 127, 0.0, 1.0);
//
// 	// Visual debug
// 	(
// 		"\nMIDI Control Change:\n" ++
// 		"Channel: %\n".format(chan) ++
// 		"Number: %\n".format(num) ++
// 		"Value: %\n".format(val) ++
// 		"Scaled: %".format(scaled)
// 	).postln;
//
// 	// Update parameters with visual feedback
// 	case
// 	{num == 1} {
// 		~beatParams.masterAmp = scaled;
// 		"Master Volume → %".format(scaled).postln;
//
// 		// Create test tone to verify volume change
// 		Synth(\elektronBell, [\freq, 440, \amp, 0.3 * scaled]);
// 	}
// 	{num == 2} {
// 		~beatParams.beatTempo = scaled.linlin(0, 1, 0.5, 2.0);
// 		"Tempo → %".format(~beatParams.beatTempo).postln;
// 	};
// }, nil, 14);
//
// "MIDI handler updated with debug output.".postln;
// )
//
// // 5. Send test transaction
// (
// n = NetAddr("localhost", 57120);
// n.sendMsg("/tx", "0xtest", 1.5, 25);
// "Test transaction sent.".postln;
// )
