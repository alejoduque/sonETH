// SuperCollider Ethereum Sonification - Server Configuration
// Current Date and Time (UTC): 2025-03-02 01:07:52
// Current User's Login: alejoduque
// Initialization Sequence: 2 of 9

(
try {
    // Initialize audio parameters
    ~audioParams ?? {
        ~audioParams = (
            masterVolume: 0.5,
            transactionVolume: 0.3,
            beatVolume: 0.4
        );
    };

    // Server config
    s = Server.local;
    s.options.numBuffers = 1024 * 16;
    s.options.memSize = 8192 * 16;
    s.options.maxNodes = 1024 * 32;
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels = 2;

    // Boot routine
    ~bootServer = {
        if(s.serverRunning.not) {
            "Booting server...".postln;
            s.boot;
        };
    };

    // Initialize resources after boot
    ~initResources = {
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
        
        "Server resources initialized.".postln;
    };

    // Cleanup routine
    ~cleanup = {
        try {
            ~audioBuses.do(_.free);
            ~controlBuses.do(_.free);
            ~rootGroup.free;
            ~mainGroup.free;
            
            ~audioBuses = nil;
            ~controlBuses = nil;
            ~rootGroup = nil;
            ~mainGroup = nil;
        } { |err| 
            "Cleanup error: %".format(err.asString).error;
        };
    };

    // Server status
    ~checkStatus = {
        var status = (
            running: s.serverRunning,
            avgCPU: s.avgCPU,
            peakCPU: s.peakCPU,
            numSynths: s.numSynths
        );
        
        [
            "\nServer Status:",
            "- Running: %".format(status.running),
            "- Average CPU: % %".format(status.avgCPU.asFloat.round(0.1), "%"),
            "- Peak CPU: % %".format(status.peakCPU.asFloat.round(0.1), "%"),
            "- Active Synths: %".format(status.numSynths)
        ].join("\n").postln;
        
        status
    };

    // Boot and initialize
    s.waitForBoot({
        try {
            ~initResources.value;
            ~checkStatus.value;
            
            ServerQuit.add({ ~cleanup.value });
            
            "Server configuration loaded and ready.".postln;
        } { |err|
            "Server initialization error: %".format(err.asString).error;
        };
    });

} { |err|
    "Server configuration error: %".format(err.asString).error;
};
)