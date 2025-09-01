// SuperCollider Ethereum Sonification - Trend Analysis
// Current Date and Time (UTC): 2025-03-02 01:15:24
// Current User's Login: alejoduque
// Initialization Sequence: 8 of 9

(
s.waitForBoot({
    try {
        var trendAnalysis = (
            values: List[],
            timeStamps: List[],
            maxSize: 100,
            analysisGroup: nil,
            
            init: { |self|
                if(~mainGroup.isNil) {
                    ~mainGroup = Group.new(s);
                };
                self.analysisGroup = Group.after(~mainGroup);
                "Trend analysis initialized.".postln;
            },
            
            add: { |self, value, time|
                if(value.notNil) {
                    self.values.add(value);
                    self.timeStamps.add(time ? SystemClock.seconds);
                    
                    while { self.values.size > self.maxSize } {
                        self.values.removeAt(0);
                        self.timeStamps.removeAt(0);
                    };
                    
                    {
                        ~mainWindow !? { ~mainWindow.refresh };
                    }.defer;
                    
                    ^self.getTrend;
                };
                ^nil;
            },
            
            getTrend: { |self|
                if(self.values.size < 5) { ^0 };
                
                var last5 = self.values.copyRange(
                    self.values.size - 5,
                    self.values.size - 1
                );
                
                if((last5.last - last5.first).abs < 0.1) { ^0 };
                ^if(last5.last > last5.first) { 1 } { -1 };
            },
            
            getMovingAverage: { |self, window=5|
                if(self.values.size < window) { ^0 };
                
                var recent = self.values.copyRange(
                    self.values.size - window,
                    self.values.size - 1
                );
                
                ^(recent.sum / window);
            },
            
            getStats: { |self|
                if(self.values.isEmpty) {
                    ^(
                        count: 0,
                        average: 0,
                        min: 0,
                        max: 0,
                        trend: 0,
                        movingAverage: 0
                    )
                };
                
                ^(
                    count: self.values.size,
                    average: self.values.mean,
                    min: self.values.minItem,
                    max: self.values.maxItem,
                    trend: self.getTrend,
                    movingAverage: self.getMovingAverage
                )
            },
            
            clear: { |self|
                self.values.clear;
                self.timeStamps.clear;
                "Trend analysis data cleared.".postln;
            },
            
            cleanup: { |self|
                self.analysisGroup !? { self.analysisGroup.free };
                self.clear;
                "Trend analysis resources freed.".postln;
            }
        );
        
        // Store globally
        ~trendAnalysis = trendAnalysis;
        
        // Initialize
        ~trendAnalysis.init;
        
        // Register cleanup
        ServerQuit.add({ 
            ~trendAnalysis !? { ~trendAnalysis.cleanup };
        });
        
        // Test the system
        fork {
            var testValues = [1.0, 1.2, 1.1, 1.3, 1.4];
            var stats;
            
            "Testing trend analysis system...".postln;
            
            testValues.do { |val|
                ~trendAnalysis.add(val);
            };
            
            stats = ~trendAnalysis.getStats;
            
            [
                "\nTrend Analysis Status:",
                "- System Active: true",
                "- Storage Capacity: %".format(~trendAnalysis.maxSize),
                "- Current Values: %".format(~trendAnalysis.values.size),
                "- Current Average: %".format(stats.average.round(0.001)),
                "- Current Trend: %".format(
                    switch(stats.trend)
                    { 1 } { "↑ Up" }
                    { -1 } { "↓ Down" }
                    { "→ Stable" }
                )
            ].join("\n").postln;
        };
        
        "Trend Analysis System loaded successfully.".postln;
        
    } { |err|
        "Trend analysis initialization error: %".format(err.asString).error;
    };
});
)