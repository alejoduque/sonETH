// SuperCollider Ethereum Sonification - System Loader
// Current Date and Time (UTC): 2025-03-03 04:58:44
// Current User's Login: alejoduque

(
// Get the directory of the current file
~baseDir = thisProcess.nowExecutingPath !? { |p| p.dirname } ?? { "".standardizePath };

~components = [
    (
        file: ~baseDir +/+ "1_server_config.scd",
        check: {
            ~rootGroup.notNil and:
            { ~audioBuses.notNil } and:
            { ~mainMonitor.notNil }  // Add monitor check
        },
        waitTime: 2
    ),
    (
        file: ~baseDir +/+ "2_synthdefs.scd",
        check: { SynthDescLib.at(\elektronBell).notNil and: { SynthDescLib.at(\beatSynth).notNil } },
        waitTime: 1
    ),
    (
		// file: ~baseDir +/+ "3_midi_control.scd",
		// check: { ~midiControl.notNil },
		// waitTime: 1
		// ),
		file: ~baseDir +/+ "3_midi_control.scd",
		check: { ~midiControl.notNil },
		waitTime: 1
	),


		(
		file: ~baseDir +/+ "4_gui.scd",
		check: { ~mainWindow.notNil and: { ~mainWindow.isClosed.not } },
		waitTime: 1
		),
    (
        file: ~baseDir +/+ "5_beat_engine.scd",
        check: {
            ~beatEngine.notNil and:
            { ~audioBuses.main.notNil }  // Verify bus exists
        },
        waitTime: 2
    ),
    (
        file: ~baseDir +/+ "6_osc_handlers.scd",
        check: { ~handleTransaction.notNil },
        waitTime: 1
    ),
    (
        file: ~baseDir +/+ "7_trend_analysis.scd",
        check: { ~trendAnalysis.notNil },
        waitTime: 1
    ),
    (
        file: ~baseDir +/+ "8_transaction_buffer.scd",
        check: { ~transactionBuffer.notNil },
        waitTime: 1
    ),
    (
        file: ~baseDir +/+ "9_main_interface.scd",
        check: { ~interface.notNil },
        waitTime: 1
    )
];

Routine({
    var loadStatus = Array.new(~components.size);

    "=== Ethereum Sonification System Loader ===".postln;
    ("Base Directory: " ++ ~baseDir).postln;

    // Make sure server is booted first
    Server.local.waitForBoot({
        // Give the server a moment to fully initialize
        2.wait;

        // Clear existing resources
        if(~mainMonitor.notNil) { ~mainMonitor.free };
        if(~beatEngine.notNil and: { ~beatEngine.running }) { ~beatEngine.stop };

        ~components.do({ |component, i|
            var success = false;
            var attempts = 0;

            ("Loading [" ++ (i+1) ++ "/9]: " ++ component.file.basename).postln;

            if(File.exists(component.file)) {
                try {
                    component.file.load;

                    // Print debug info after server config
                    if(i == 0) {
                        ("Server config loaded - Main bus index: " ++ ~audioBuses.main.index).postln;
                    };

                    // Print debug info before beat engine
                    if(i == 4) {
                        ("Before beat engine - Main bus index: " ++ ~audioBuses.main.index).postln;
                    };

                    // Wait for the specified time
                    component.waitTime.wait;

                    while {
                        attempts = attempts + 1;
                        success = component.check.value;
                        success.not and: { attempts < 10 }
                    } {
                        0.2.wait;
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

            // Additional wait between components
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

        // Final test of beat engine with debug info
        if(loadStatus.every(_ == true)) {
            "\nTesting beat engine:".postln;
            ("Main bus index: " ++ ~audioBuses.main.index).postln;
            ("Monitor active: " ++ ~mainMonitor.notNil).postln;
            ~beatEngine.start;
        };
    });
}).play;
)