// SuperCollider Ethereum Sonification - System Initialization
// Current Date and Time (UTC): 2025-03-01 05:12:19
// Current User's Login: alejoduque

(
// Server configuration
s.options.memSize = 8192 * 16;
s.options.numBuffers = 1024 * 16;
s.options.maxNodes = 1024 * 16;
s.options.numAudioBusChannels = 128;
s.options.numControlBusChannels = 4096;
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 2;
s.options.memoryLocking = true;
s.options.threads = 4;

// Global variables
~globalState = (
    isPlaying: false,
    midiInitialized: false,
    oscInitialized: false,
    lastTransactionTime: 0,
    transactionCount: 0,
    fadeTime: 0.5
);

// Initialize parameter dictionaries
~beatParams = (
    beatTempo: 1.0,
    droneFade: 2.0,
    droneSpace: 0.5,
    droneMix: 0.5,
    droneRes: 0.4,
    droneDepth: 0.3,
    noiseLevel: 0.1,
    noiseFilt: 0.5,
    masterAmp: 0.7,
    delayFeedback: 0.3,
    filterCutoff: 0.6
);

// Initialize control buses
~buses = ~buses ?? ();
~controlBuses = ~controlBuses ?? ();

// Audio control buses
[
    \volume, \fmRatio, \fmDepth, \grainSize, \grainDensity,
    \filterFreq, \decay, \delayMix, \reverbMix, \pitchOffset,
    \bellTone, \bellRes, \bellSpread, \playbackRate
].do { |name|
    ~buses[name] = Bus.control(s, 1).set(1);
};

// Beat control buses
~beatParams.keysValuesDo { |key, value|
    ~controlBuses[key] = Bus.control(s, 1).set(value);
};

"Initialization complete.".postln;
)