// SuperCollider Ethereum Sonification - Server Configuration
// Current Date and Time (UTC): 2025-03-01 22:23:45
// Current User's Login: alejoduque

(
// Configure server options before booting
Server.default.options.numBuffers = 1024 * 16;
Server.default.options.memSize = 8192 * 16;
Server.default.options.maxNodes = 1024 * 32;
Server.default.options.numOutputBusChannels = 2;
Server.default.options.numInputBusChannels = 2;

// Create initialization routine
~serverInitRoutine = Routine({
    // Boot server if not already running
    if(Server.default.serverRunning.not) {
        "Booting server...".postln;
        Server.default.boot;
        Server.default.waitForBoot;
        2.wait;
    };
    
    "Server booted, initializing components...".postln;
    
    // First, load the basic elektronBell SynthDef
    SynthDef(\elektronBell, {
        arg freq=440, amp=0.3, 
            atk=0.01, dec=0.3, rel=0.5,
            tone=0.3, res=0.4, pan=0;
        
        var env, sig, mod;
        
        // FM Synthesis
        mod = SinOsc.ar(freq * 1.5) * 0.5 * freq;
        sig = SinOsc.ar(freq + mod);
        
        // Envelope
        env = EnvGen.kr(
            Env.new(
                [0, 1, 0.5, 0],
                [atk, dec, rel],
                [-4, -2, -4]
            ),
            doneAction: 2
        );
        
        sig = sig * env * amp;
        sig = Pan2.ar(sig, pan);
        
        Out.ar(0, sig);
    }).add;
    
    Server.default.sync;
    1.wait;
    
    // Test the synth
    "Testing elektronBell synth...".postln;
    Synth(\elektronBell, [\freq, 440, \amp, 0.3]);
    
    // Create server status check function
    ~checkServerStatus = {
        (
            "\nServer Status:".postln;
            "- Running: %".format(Server.default.serverRunning).postln;
            "- Average CPU: % %".format(Server.default.avgCPU.round(0.1), "%").postln;
            "- Peak CPU: % %".format(Server.default.peakCPU.round(0.1), "%").postln;
            "- Active Synths: %".format(Server.default.numSynths).postln;
            "- SynthDef loaded: %".format(SynthDescLib.global.synthDescs.at(\elektronBell).notNil).postln;
        )
    };
    
    // Initialize OSC
    "Initializing OSC...".postln;
    OSCdef(\txHandler).free; // Clear any existing handler
    
    OSCdef(\txHandler, {|msg, time, addr, port|
        var txHash = msg[1].asString;
        var value = msg[2].asFloat;
        var gasPrice = msg[3].asFloat;
        
        (
            "\nTransaction Received:".postln;
            "Hash: %".format(txHash).postln;
            "Value: % ETH".format(value).postln;
            "Gas: % gwei".format(gasPrice).postln;
        );
        
        Synth(\elektronBell, [
            \freq, value.linexp(0.001, 10, 200, 800),
            \amp, value.linlin(0.001, 10, 0.2, 0.5),
            \dec, gasPrice.linlin(1, 100, 0.5, 2.0),
            \pan, txHash.hash.fold(-1.0, 1.0)
        ]);
    }, '/tx');
    
    // Test functions
    ~testSound = {
        Synth(\elektronBell, [\freq, 440, \amp, 0.3]);
    };
    
    ~testTransaction = {
        var testAddr = NetAddr("localhost", 57120);
        "Sending test transaction...".postln;
        testAddr.sendMsg("/tx", "0xtest", 1.5, 25);
    };
    
    ~startOSCMonitor = {
        "OSC monitoring enabled...".postln;
        OSCFunc.trace(true);
    };
    
    ~stopOSCMonitor = {
        "OSC monitoring disabled".postln;
        OSCFunc.trace(false);
    };
    
    (
        "\nServer configuration complete:".postln;
        "- Use ~checkServerStatus.value; to check server status".postln;
        "- Use ~testSound.value; to test audio".postln;
        "- Use ~testTransaction.value; to test transactions".postln;
        "- Use ~startOSCMonitor.value; to debug OSC".postln;
    );
});

// Run the initialization routine
SystemClock.play(~serverInitRoutine);
)