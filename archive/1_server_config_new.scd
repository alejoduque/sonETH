// SuperCollider Ethereum Sonification - Server Configuration
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-03 18:01:09
// Current User's Login: alejoduque

(
s.waitForBoot({
    // Configure server
    s.options.numBuffers = 1024 * 16;
    s.options.memSize = 8192 * 16;
    s.options.maxNodes = 1024 * 32;
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels = 2;
    
    s.sync;
    
    // Create groups
    ~rootGroup = Group.new;
    ~mainGroup = Group.after(~rootGroup);
    
    // Initialize control values first
    ~controlValues = (
        volume: 0.3,
        fmratio: 1.0,
        grainsize: 0.1,
        filterfreq: 1000
    );
    
    // Create audio buses
    ~audioBuses = (
        main: Bus.audio(s, 2),
        effects: Bus.audio(s, 2),
        transactions: Bus.audio(s, 2)
    );
    
    // Create control buses
    ~controlBuses = (
        volume: Bus.control(s, 1).set(~controlValues.volume),
        fmratio: Bus.control(s, 1).set(~controlValues.fmratio),
        grainsize: Bus.control(s, 1).set(~controlValues.grainsize),
        filterfreq: Bus.control(s, 1).set(~controlValues.filterfreq)
    );
    
    // Audio parameters
    ~audioParams = (
        masterVolume: 0.5,
        transactionVolume: 0.3,
        beatVolume: 0.6
    );
    
    // Control specs for MIDI and GUI
    ~controlSpecs = (
        volume: ControlSpec(0, 1, \lin),
        fmratio: ControlSpec(0.5, 4, \exp),
        grainsize: ControlSpec(0.01, 0.5, \exp),
        filterfreq: ControlSpec(200, 5000, \exp)
    );
    
    // Create monitor synth
    SynthDef(\mainMonitor, {
        arg in=0, out=0, amp=1;
        var sig = In.ar(in, 2) * amp;
        Out.ar(out, sig);
    }).add;
    
    s.sync;
    
    // Create the monitor
    ~mainMonitor = Synth.tail(~rootGroup, \mainMonitor, [
        \in, ~audioBuses.main,
        \out, 0,
        \amp, 1
    ]);
    
    // Test audio routing
    {
        SynthDef(\testBeep, {
            arg out=0, freq=440, amp=0.2;
            var env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction: 2);
            var sig = SinOsc.ar(freq) * env * amp;
            Out.ar(out, sig!2);
        }).add;
        
        s.sync;
        
        // Test direct output
        Synth(\testBeep, [\out, 0, \freq, 440]);
        0.5.wait;
        
        // Test through bus system
        Synth(\testBeep, [\out, ~audioBuses.main, \freq, 880]);
        
        "\nAudio System Status:".postln;
        "-------------------".postln;
        ("Main audio bus index: " ++ ~audioBuses.main.index).postln;
        ("Monitor synth active: " ++ ~mainMonitor.notNil).postln;
        
        "\nControl System Status:".postln;
        "-------------------".postln;
        ~controlValues.keysValuesDo({ |key, val|
            ("Control '%': %".format(key, val)).postln;
        });
        
        ~controlBuses.keysValuesDo({ |key, bus|
            ("Bus '%': %".format(key, bus.index)).postln;
        });
    }.fork;
    
    "Server configuration complete.".postln;
});
)