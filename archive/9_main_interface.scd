// SuperCollider Ethereum Sonification - Main Interface
// Current Date and Time (UTC): 2025-03-02 06:18:59
// Current User's Login: alejoduque

(
~interface = (
    monitoring: false,
    oscCount: 0,
    midiCount: 0,
    monitorRoutine: nil,
    debug: true, // Enable debug mode

    // Status check remains the same...

    // Enhanced start monitoring with debug
    startMonitoring: {
        if(~interface.monitoring.not) {
            ~interface.monitoring = true;
            
            // Reset counters
            ~interface.oscCount = 0;
            ~interface.midiCount = 0;

            // Debug current OSC state
            ["Current OSC Port:", NetAddr.localAddr.port].postln;
            
            // Note handler with explicit debug
            OSCFunc({ |msg, time, addr, port|
                if(~interface.debug) {
                    ["Received ETH Note:", 
                     "\n  Path:", msg[0],
                     "\n  Note:", msg[1],
                     "\n  Velocity:", msg[2],
                     "\n  Instrument:", msg[3],
                     "\n  Duration:", msg[4],
                     "\n  From:", addr, port
                    ].join("").postln;
                };
                
                ~interface.oscCount = (~interface.oscCount ? 0) + 1;
                
                // Try to handle the transaction
                try {
                    if(~handleTransaction.notNil) {
                        ~handleTransaction.value(
                            msg[1].asFloat,
                            msg[2].asFloat / 127,
                            msg[4].asFloat,
                            msg[3].asInteger
                        );
                    };
                } { |error|
                    ["Transaction handler error:", error].postln;
                };
            }, '/eth/note', nil, 57120);  // Explicitly set port

            // Transaction info handler with debug
            OSCFunc({ |msg, time, addr, port|
                if(~interface.debug) {
                    ["Received TX Info:",
                     "\n  Path:", msg[0],
                     "\n  Hash:", msg[1],
                     "\n  Value:", msg[2],
                     "\n  Gas:", msg[3],
                     "\n  To:", msg[4],
                     "\n  From:", addr, port
                    ].join("").postln;
                };
                
                ~interface.oscCount = (~interface.oscCount ? 0) + 1;
                
                // Update GUI
                {
                    if(~gui.notNil) {
                        ~gui.lastTxInfo = "TX: % (% ETH)".format(
                            msg[1].asString,
                            msg[2].asFloat
                        );
                    };
                }.defer;
            }, '/eth/tx_info', nil, 57120);  // Explicitly set port

            // Debug handler for all OSC
            OSCFunc({ |msg, time, addr, port|
                if(~interface.debug and: {
                    (msg[0] != '/eth/note') and: 
                    (msg[0] != '/eth/tx_info')
                }) {
                    ["Other OSC:", msg[0], msg[1..], addr, port].postln;
                };
            }, nil, nil, 57120);

            // Enhanced test function
            ~interface.testEthMessages = {
                var testAddr = NetAddr("localhost", 57120);
                
                // Test both message types
                testAddr.sendMsg("/eth/note", 60, 100, 1, 0.5);
                ["Sent test note message"].postln;
                
                testAddr.sendMsg("/eth/tx_info", 
                    "0x1234abcd", // hash
                    1.5,          // value in ETH
                    50,           // gas price
                    "0xdead..beef" // to address
                );
                ["Sent test tx info"].postln;
            };

            // Status update routine
            ~interface.monitorRoutine = Routine({
                loop {
                    ~interface.status;
                    5.wait;
                }
            }).play;

            "Monitoring started with debug mode.".postln;
        } {
            "Already monitoring.".warn;
        }
    },

    // Rest of interface code remains the same...
);

// Add immediate debug command
~checkOSC = {
    ["Current OSC Status:",
     "\n  Local Address:", NetAddr.localAddr,
     "\n  Local Port:", NetAddr.localAddr.port,
     "\n  Active Responders:", OSCFunc.all.size
    ].join("").postln;
    
    // Test local OSC
    ~interface.testEthMessages;
};

// Initialize
~interface.status;
"Main interface ready with debugging.".postln;
"Use ~checkOSC to test OSC system.".postln;

// Register cleanup
ServerQuit.add({ ~interface.cleanup });
)