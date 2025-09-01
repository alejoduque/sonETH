// SuperCollider Ethereum Sonification - Trend Analysis
// Current Date and Time (UTC): 2025-08-31 21:48:00
// Current User's Login: alejoduque

(
// Initialize global variables for trend analysis
~trendDataPoints = List[];
~trendTimeStamps = List[];
~trendMaxSize = 100;

// Add new value function
~addTrendValue = { |value, time|
    ~trendDataPoints.add(value);
    ~trendTimeStamps.add(time ? SystemClock.seconds);
    
    // Keep only last maxSize entries
    if(~trendDataPoints.size > ~trendMaxSize) {
        ~trendDataPoints.removeAt(0);
        ~trendTimeStamps.removeAt(0);
    };
};

// Get trend direction (-1: down, 0: stable, 1: up)
~getTrend = {
    var last5, diff;
    if(~trendDataPoints.size < 5) {
        0
    } {
        last5 = ~trendDataPoints.copyRange(~trendDataPoints.size-5, ~trendDataPoints.size-1);
        diff = last5.last - last5.first;
        case
        { diff > 0.1 } { 1 }
        { diff < -0.1 } { -1 }
        { true } { 0 }
    }
};

// Get moving average
~getMovingAverage = { |window=5|
    var dataSlice;
    if(~trendDataPoints.size < window) {
        0
    } {
        dataSlice = ~trendDataPoints.copyRange(~trendDataPoints.size-window, ~trendDataPoints.size-1);
        dataSlice.sum / window
    }
};

// Test the trend analysis
~addTrendValue.value(1.0);
~addTrendValue.value(1.2);
~addTrendValue.value(1.1);
~addTrendValue.value(1.3);
~addTrendValue.value(1.4);

"Trend Analysis System loaded.".postln;
"Current trend: %".format(~getTrend.value).postln;
"Moving average: %".format(~getMovingAverage.value).postln;
)