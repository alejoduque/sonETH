// SuperCollider Ethereum Sonification - System Test
// Current Date and Time (UTC): 2025-03-01 22:59:03
// Current User's Login: alejoduque

(
// Test routine
~testSystem = Routine({
    var testResults = List[];
    
    "Testing system components...".postln;
    
    // 1. Test server
    testResults.add(
        try {
            Server.default.serverRunning
        } { |error|
            ("Server test failed: " ++ error.errorString).error;
            false
        }
    );
    
    // 2. Test synthdefs
    testResults.add(
        try {
            SynthDescLib.global.synthDescs.at(\elektronBell).notNil
        } { |error|
            ("SynthDef test failed: " ++ error.errorString).error;
            false
        }
    );
    
    // 3. Test MIDI
    testResults.add(
        try {
            MIDIClient.initialized
        } { |error|
            ("MIDI test failed: " ++ error.errorString).error;
            false
        }
    );
    
    // 4. Test GUI
    testResults.add(
        try {
            ~mainWindow.notNil
        } { |error|
            ("GUI test failed: " ++ error.errorString).error;
            false
        }
    );
    
    // 5. Test beat engine
    testResults.add(
        try {
            ~beatEngine.notNil and: {~beatEngine.createPattern.().isKindOf(Pattern)}
        } { |error|
            ("Beat engine test failed: " ++ error.errorString).error;
            false
        }
    );
    
    // 6. Test OSC
    testResults.add(
        try {
            OSCdef(\txHandler).notNil
        } { |error|
            ("OSC test failed: " ++ error.errorString).error;
            false
        }
    );
    
    // 7. Test trend analysis
    testResults.add(
        try {
            ~trendAnalysis.notNil and: {~trendAnalysis.values.notNil}
        } { |error|
            ("Trend analysis test failed: " ++ error.errorString).error;
            false
        }
    );
    
    // 8. Test transaction buffer
    testResults.add(
        try {
            ~transactionBuffer.notNil and: {~transactionBuffer.transactions.notNil}
        } { |error|
            ("Transaction buffer test failed: " ++ error.errorString).error;
            false
        }
    );
    
    // Print results
    (
        "\nTest Results:".postln;
        "============".postln;
        "Server: %".format(if(testResults[0], "✓", "✗")).postln;
        "SynthDefs: %".format(if(testResults[1], "✓", "✗")).postln;
        "MIDI: %".format(if(testResults[2], "✓", "✗")).postln;
        "GUI: %".format(if(testResults[3], "✓", "✗")).postln;
        "Beat Engine: %".format(if(testResults[4], "✓", "✗")).postln;
        "OSC: %".format(if(testResults[5], "✓", "✗")).postln;
        "Trend Analysis: %".format(if(testResults[6], "✓", "✗")).postln;
        "Transaction Buffer: %".format(if(testResults[7], "✓", "✗")).postln;
        "\nOverall Status: %".format(
            if(testResults.indexOf(false).isNil, "✓ All tests passed", "✗ Some tests failed"
        )).postln;
    );
});

// Run tests
~testSystem.play;
)