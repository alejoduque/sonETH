// SuperCollider Ethereum Sonification - Server Configuration
// Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-03-03 23:50:35
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
        filterfreq: 1000,
        pitchoffset: 0,
        fmdepth: 0.2,
        graindensity: 10,
        decay: 1.5,
        delaymix: 0.2,
        reverbmix: 0.3
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
        filterfreq: Bus.control(s, 1).set(~controlValues.filterfreq),
        pitchoffset: Bus.control(s, 1).set(~controlValues.pitchoffset),
        fmdepth: Bus.control(s, 1).set(~controlValues.fmdepth),
        graindensity: Bus.control(s, 1).set(~controlValues.graindensity),
        decay: Bus.control(s, 1).set(~controlValues.decay),
        delaymix: Bus.control(s, 1).set(~controlValues.delaymix),
        reverbmix: Bus.control(s, 1).set(~controlValues.reverbmix)
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
        filterfreq: ControlSpec(200, 5000, \exp),
        pitchoffset: ControlSpec(-12, 12, \lin),
        fmdepth: ControlSpec(0, 1, \lin),
        graindensity: ControlSpec(5, 50, \exp),
        decay: ControlSpec(0.5, 3, \lin),
        delaymix: ControlSpec(0, 1, \lin),
        reverbmix: ControlSpec(0, 1, \lin)
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
    
    // Helper functions for debugging
    ~checkAudio = {
        [
            "Audio System Status:",
            "Server running: %".format(s.serverRunning),
            "Main bus index: %".format(~audioBuses.main.index),
            "Monitor active: %".format(~mainMonitor.notNil),
            "Master volume: %".format(~controlBuses.volume.getSynchronous),
            "\nTo test audio:",
            "1. ~testBeep.value;  // Test main output",
            "2. ~beatEngine.start;  // Start beat engine",
            "3. ~testTransaction.value;  // Test transaction sound"
        ].join("\n").postln;
    };
    
    ~testBeep = {
        Synth(\testBeep, [\out, ~audioBuses.main, \freq, 880]);
        "Test beep triggered.".postln;
    };
    
    // Register cleanup
    ServerQuit.add({
        if(~mainMonitor.notNil) { ~mainMonitor.free };
        ~audioBuses.do(_.free);
        ~controlBuses.do(_.free);
        ~rootGroup.free;
        ~mainGroup.free;
    });
    
    "Server configuration complete.".postln;
});
)