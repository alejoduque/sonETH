// SuperCollider-Python Connection Test
// Current Date and Time (UTC): 2025-03-01 00:04:34
// Current User's Login: alejoduque

(
// First, reset Server
s.quit;
s.options.memSize = 8192 * 16;
s.options.numBuffers = 1024 * 16;
s.options.maxNodes = 1024 * 16;
s.options.numWireBufs = 64 * 16;
s.boot;

// Wait for server to boot
s.waitForBoot({
    "Server booted, testing OSC...".postln;
    
    // Clear all existing OSC defs
    OSCdef.all.do(_.free);
    
    // Simple test synth
    SynthDef(\testBeep, {
        var sig = SinOsc.ar(440) * EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2) * 0.1;
        Out.ar(0, sig!2);
    }).add;
    
    // Test OSC handler
    OSCdef(\testHandler, { |msg, time, addr, recvPort|
        "Received test message!".postln;
        "Content: %".format(msg).postln;
        Synth(\testBeep);
    }, '/eth/note');
    
    // Verify port
    ("Listening on port: " ++ NetAddr.langPort).postln;
    
    // Additional debug info
    "Current NetAddr settings:".postln;
    NetAddr.all.do({ |addr| addr.postln });
});
)