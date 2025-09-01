// SuperCollider Ethereum Sonification - Transaction Buffer
// Current Date and Time (UTC): 2025-03-02 00:39:51
// Current User's Login: alejoduque
// Initialization Sequence: 9 of 9
// Depends on: 0_init.scd, 1_server_config.scd, 7_trend_analysis.scd
// Required by: none

(
protect({
    // Initialize transaction buffer state
    ~transactionBuffer = Environment.make({
        ~version = "v9";
        ~maxSize = 1000;
        ~transactions = List[];
        ~timestamps = List[];
        ~values = List[];
        ~hashes = List[];
        ~statisticsWindow = 60; // seconds
        
        ~init = {
            ~clear.value;
            "Transaction Buffer % initialized".format(~version).postln;
        };
        
        ~add = { |transaction|
            var now = SystemClock.seconds;
            
            // Validate transaction
            if(transaction.isNil) {
                "Warning: Nil transaction passed to buffer".warn;
                ^false;
            };
            
            // Add to buffer
            ~transactions.add(transaction);
            ~timestamps.add(now);
            ~values.add(transaction[\value] ?? 0);
            ~hashes.add(transaction[\hash] ?? "0x0");
            
            // Maintain buffer size
            while({ ~transactions.size > ~maxSize }) {
                ~transactions.removeAt(0);
                ~timestamps.removeAt(0);
                ~values.removeAt(0);
                ~hashes.removeAt(0);
            };
            
            // Update trend analysis if available
            ~trendAnalysis !? {
                ~trendAnalysis.use { 
                    ~add.value(transaction[\value] ?? 0, now);
                };
            };
            
            // Update beat engine if available
            ~beatEngine !? {
                ~beatEngine.use {
                    ~setTransactionInfluence.value(
                        ~getRecentActivity.value / ~maxSize
                    );
                };
            };
            
            ^true;
        };
        
        ~getRecentActivity = { |seconds|
            var now = SystemClock.seconds;
            var cutoff = now - (seconds ?? ~statisticsWindow);
            
            ~timestamps.count({ |timestamp|
                timestamp >= cutoff
            });
        };
        
        ~getStatistics = {
            var recentValues, stats;
            
            if(~values.isEmpty) {
                ^(
                    count: 0,
                    average: 0,
                    median: 0,
                    min: 0,
                    max: 0,
                    recentActivity: 0
                )
            };
            
            recentValues = ~values.select({ |val, i|
                ~timestamps[i] >= (SystemClock.seconds - ~statisticsWindow)
            });
            
            stats = (
                count: ~values.size,
                average: if(recentValues.notEmpty) {
                    recentValues.mean
                } { 0 },
                median: if(recentValues.notEmpty) {
                    recentValues.sort[recentValues.size >> 1]
                } { 0 },
                min: if(recentValues.notEmpty) {
                    recentValues.minItem
                } { 0 },
                max: if(recentValues.notEmpty) {
                    recentValues.maxItem
                } { 0 },
                recentActivity: ~getRecentActivity.value
            );
            
            ^stats;
        };
        
        ~getLast = { |n = 1|
            var result = List[];
            n = min(n, ~transactions.size);
            
            n.do({ |i|
                var idx = ~transactions.size - 1 - i;
                if(idx >= 0) {
                    result.add((
                        transaction: ~transactions[idx],
                        timestamp: ~timestamps[idx],
                        value: ~values[idx],
                        hash: ~hashes[idx]
                    ));
                };
            });
            
            ^result;
        };
        
        ~clear = {
            ~transactions.clear;
            ~timestamps.clear;
            ~values.clear;
            ~hashes.clear;
            "Transaction buffer cleared.".postln;
        };
        
        ~monitor = {
            var stats = ~getStatistics.value;
            var lastTx = ~getLast.value(1);
            
            (
                "\nTransaction Buffer Status:".postln;
                "- Buffer Size: % / %".format(~transactions.size, ~maxSize).postln;
                "- Recent Activity: % tx/%s".format(
                    stats.recentActivity, 
                    ~statisticsWindow
                ).postln;
                "- Average Value: % ETH".format(
                    stats.average.round(0.001)
                ).postln;
                if(lastTx.notEmpty) {
                    "- Last Transaction: % ETH (%)".format(
                        lastTx[0].value.round(0.001),
                        lastTx[0].hash[0..9] ++ "..."
                    ).postln;
                };
            );
        };
    });
    
    // Initialize buffer
    ~transactionBuffer.use { ~init.value };
    
    // Setup monitoring
    ~monitorBuffer = Routine({
        inf.do {
            ~transactionBuffer.use { ~monitor.value };
            5.wait;
        };
    });
    
    // Test the buffer
    protect({
        ~transactionBuffer.use({
            // Add some test transactions
            5.do({ |i|
                ~add.value((
                    value: 1.5 + i,
                    hash: "0xtest%".format(i),
                    timestamp: SystemClock.seconds
                ));
            });
            
            // Show initial status
            ~monitor.value;
        });
        
        "Transaction Buffer % loaded and ready.".format(
            ~transactionBuffer.use { ~version }
        ).postln;
        
    }, { |error|
        "Transaction buffer test error: %".format(error.what).error;
    });
    
    // Register cleanup
    ServerQuit.add({
        protect({
            ~monitorBuffer.stop;
            ~transactionBuffer.use { ~clear.value };
            ~transactionBuffer = nil;
        }, { |error|
            "Transaction buffer cleanup error: %".format(error.what).error;
        });
    });
    
}, { |error|
    "Transaction buffer initialization error: %".format(error.what).error;
});
)