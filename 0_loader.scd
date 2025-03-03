// SuperCollider Ethereum Sonification - System Loader
// Current Date and Time (UTC): 2025-03-02 05:38:23
// Current User's Login: alejoduque

(
// Get the directory of the current file
~baseDir = thisProcess.nowExecutingPath !? { |p| p.dirname } ?? { "".standardizePath };

~components = [
    (
        file: ~baseDir +/+ "1_server_config.scd",
        check: { ~mainGroup.notNil and: { ~audioBuses.notNil } }
    ),
    (
        file: ~baseDir +/+ "2_synthdefs.scd",
        check: { SynthDescLib.at(\elektronBell).notNil and: { SynthDescLib.at(\beatSynth).notNil } }
    ),
    (
        file: ~baseDir +/+ "3_midi_control.scd",
        check: { ~midiControl.notNil }
    ),
    (
        file: ~baseDir +/+ "4_gui.scd",
        check: { ~mainWindow.notNil and: { ~mainWindow.isClosed.not } }
    ),
    (
        file: ~baseDir +/+ "5_beat_engine.scd",
        check: { ~beatEngine.notNil }
    ),
    (
        file: ~baseDir +/+ "6_osc_handlers.scd",
        check: { ~handleTransaction.notNil }
    ),
    (
        file: ~baseDir +/+ "7_trend_analysis.scd",
        check: { ~trendAnalysis.notNil }
    ),
    (
        file: ~baseDir +/+ "8_transaction_buffer.scd",
        check: { ~transactionBuffer.notNil }
    ),
    (
        file: ~baseDir +/+ "9_main_interface.scd",
        check: { ~interface.notNil }
    )
];

Routine({
    var loadStatus = Array.new(~components.size);
    
    "=== Ethereum Sonification System Loader ===".postln;
    ("Base Directory: " ++ ~baseDir).postln;
    
    s.waitForBoot({
        s.sync;
        
        ~components.do({ |component, i|
            var success = false;
            var attempts = 0;
            
            ("Loading [" ++ (i+1) ++ "/9]: " ++ component.file.basename).postln;
            
            if(File.exists(component.file)) {
                try {
                    component.file.load;
                    s.sync;
                    
                    while { 
                        attempts = attempts + 1;
                        success = component.check.value;
                        success.not and: { attempts < 10 }
                    } {
                        0.1.wait;
                    };
                    
                    loadStatus.add(success);
                    if(success) {
                        "✓ Loaded and initialized successfully".postln;
                    } {
                        "✗ Loaded but failed to initialize".postln;
                    };
                } { |err|
                    loadStatus.add(false);
                    ("✗ Error loading: " ++ err.what).postln;
                };
            } {
                ("File does not exist: " ++ component.file.basename).error;
                loadStatus.add(false);
            };
            
            1.wait;
        });
        
        "\nLoad Summary:".postln;
        "Successful: %/%".format(
            loadStatus.count(true),
            loadStatus.size
        ).postln;
        
        if(loadStatus.includes(false)) {
            "\nFailed components:".postln;
            loadStatus.do({ |status, i|
                if(status.not) {
                    ("- " ++ ~components[i].file.basename).postln;
                };
            });
        };
    });
}).play;
)