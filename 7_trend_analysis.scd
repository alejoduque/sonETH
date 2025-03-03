// Current Date and Time (UTC): 2025-03-02 05:40:49
// Current User's Login: alejoduque

(
~trendAnalysis = (
    values: List[],
    maxSize: 100,
    
    add: { |self, value|
        self.values.add(value);
        if(self.values.size > self.maxSize) {
            self.values.removeAt(0);
        };
    },
    
    getMovingAverage: { |self, window=5|
        var start = max(0, self.values.size - window);
        var slice = self.values.copyRange(start, self.values.size - 1);
        if(slice.size > 0) {
            slice.sum / slice.size;
        } {
            0
        };
    },
    
    getTrend: { |self|
        if(self.values.size >= 5) {
            var slice = self.values.copyRange(
                self.values.size - 5,
                self.values.size - 1
            );
            var diff = slice.differentiate.drop(1);
            var trend = diff.sum.sign;
            trend;
        } {
            0
        };
    },
    
    getStats: { |self|
        (
            currentValue: self.values.last ?? 0,
            average: self.getMovingAverage(5),
            trend: self.getTrend
        )
    }
);

"Trend analysis system initialized.".postln;
)