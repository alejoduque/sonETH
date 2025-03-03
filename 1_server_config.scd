// SuperCollider Ethereum Sonification - Server Configuration
// Date: 2025-03-02 05:05:06
// User: alejoduque
// Initialization: 1/9

(
// Initialize audio parameters
~audioParams = (
    masterVolume: 0.5,
    transactionVolume: 0.3,
    beatVolume: 0.4
);

// Configure server
s = Server.local;
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 16;
s.options.maxNodes = 1024 * 32;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;

s.waitForBoot({
    // Create groups
    ~rootGroup = Group.new(s);
    s.sync;
    ~mainGroup = Group.after(~rootGroup);
    s.sync;
    
    // Setup buses
    ~audioBuses = (
        main: Bus.audio(s, 2),
        effects: Bus.audio(s, 2),
        transactions: Bus.audio(s, 2)
    );
    
    ~controlBuses = (
        volume: Bus.control(s, 1).set(~audioParams.masterVolume),
        transactionVolume: Bus.control(s, 1).set(~audioParams.transactionVolume),
        beatVolume: Bus.control(s, 1).set(~audioParams.beatVolume)
    );
    
    "Server configuration loaded and ready.".postln;
});

// Cleanup on quit
ServerQuit.add({
    ~audioBuses.do(_.free);
    ~controlBuses.do(_.free);
    ~rootGroup.free;
    ~mainGroup.free;
});
)