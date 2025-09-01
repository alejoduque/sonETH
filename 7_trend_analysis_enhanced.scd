// SuperCollider Ethereum Sonification - Enhanced Trend Analysis
// Current Date and Time (UTC): 2025-02-28 23:46:07
// Current User's Login: alejoduque

(
// Enhanced trend analysis parameters
~trendAnalysis = (
    window: 20,
    predictiveWindow: 30,  // Window for future predictions
    alertThresholds: (
        price: Dictionary.new,
        volume: Dictionary.new
    ),
    movingAverages: (
        short: 5,
        medium: 20,
        long: 50
    )
);

// Initialize alert system
~priceAlerts = (
    high: Dictionary.new,
    low: Dictionary.new,
    active: true,
    soundEnabled: true
);

// Enhanced prediction algorithm using multiple methods
~calculateEnhancedPrediction = { |points|
    var values = points.collect(_.value);
    var times = points.collect(_.time);
    var prediction;
    
    // Exponential smoothing parameters
    var alpha = 0.3;  // Smoothing factor
    var beta = 0.1;   // Trend smoothing factor
    var gamma = 0.1;  // Seasonal smoothing factor
    
    // Calculate different prediction components
    var linearPrediction = ~calculateLinearRegression.value(
        Array.series(values.size, 0, 1),
        values
    );
    
    var expSmoothing = ~calculateExpSmoothing.value(
        values,
        alpha,
        beta,
        gamma
    );
    
    var weightedAvg = ~calculateWeightedMA.value(
        values,
        [0.4, 0.3, 0.2, 0.1]  // Weights favoring recent data
    );
    
    // Combine predictions with adaptive weights
    var confidence = ~calculatePredictionConfidence.value(
        values,
        linearPrediction,
        expSmoothing,
        weightedAvg
    );
    
    // Return combined prediction with confidence
    (
        value: (
            linearPrediction.value * confidence.linear +
            expSmoothing.value * confidence.exp +
            weightedAvg * confidence.weighted
        ) / (confidence.linear + confidence.exp + confidence.weighted),
        confidence: confidence,
        components: (
            linear: linearPrediction,
            exp: expSmoothing,
            weighted: weightedAvg
        )
    )
};

// Exponential smoothing calculation
~calculateExpSmoothing = { |values, alpha, beta, gamma|
    var level = values[0];
    var trend = values[1] - values[0];
    var seasonal = Array.fill(12, 0);
    var smoothed = Array.new(values.size);
    
    values.do { |val, i|
        var oldLevel = level;
        level = (alpha * val) + ((1 - alpha) * (level + trend));
        trend = (beta * (level - oldLevel)) + ((1 - beta) * trend);
        seasonal[i % 12] = (gamma * (val - level)) + ((1 - gamma) * seasonal[i % 12]);
        smoothed.add(level + trend + seasonal[i % 12]);
    };
    
    (
        value: smoothed.last,
        trend: trend,
        seasonal: seasonal
    )
};

// Weighted Moving Average
~calculateWeightedMA = { |values, weights|
    var windowSize = weights.size;
    var result = 0;
    
    values.takeRight(windowSize).reverseDo { |val, i|
        result = result + (val * weights[i]);
    };
    
    result
};

// Calculate prediction confidence
~calculatePredictionConfidence = { |values, linear, exp, weighted|
    var recentVolatility = ~calculateVolatility.value(values.takeRight(10));
    var trendStrength = ~calculateTrendStrength.value(values);
    
    (
        linear: if(trendStrength > 0.7, 0.5, 0.3),
        exp: if(recentVolatility < 0.3, 0.4, 0.2),
        weighted: if(recentVolatility > 0.5, 0.4, 0.3)
    )
};

// Calculate volatility
~calculateVolatility = { |values|
    var mean = values.mean;
    var variance = values.collect({ |val|
        (val - mean).squared
    }).sum / values.size;
    
    variance.sqrt
};

// Calculate trend strength
~calculateTrendStrength = { |values|
    var regression = ~calculateLinearRegression.value(
        Array.series(values.size, 0, 1),
        values
    );
    
    regression.b.abs / values.mean
};

// Price Alert System
~addAlertWindow = {
    var window = Window("ETH Price Alerts", Rect(1300, 100, 300, 400));
    var layout = VLayout();
    
    // Alert controls
    layout.add(
        HLayout(
            StaticText().string_("Alerts:"),
            Button()
                .states_([
                    ["Enabled", Color.black, Color.green],
                    ["Disabled", Color.white, Color.red]
                ])
                .action_({ |but|
                    ~priceAlerts.active = but.value == 0;
                }),
            Button()
                .states_([
                    ["🔊", Color.black, Color.white],
                    ["🔇", Color.white, Color.gray]
                ])
                .action_({ |but|
                    ~priceAlerts.soundEnabled = but.value == 0;
                })
        )
    );
    
    // Add alert interface
    layout.add(
        HLayout(
            NumberBox()
                .step_(0.001)
                .scroll_step_(0.001)
                .value_(0.1),
            PopUpMenu()
                .items_(["Above", "Below"])
                .value_(0),
            Button()
                .states_([["Add Alert"]])
                .action_({ |but|
                    var val = but.parent.children[0].value;
                    var type = but.parent.children[1].value;
                    ~addPriceAlert.value(val, type);
                })
        )
    );
    
    // Alert list
    ~alertList = ListView()
        .background_(Color.black)
        .stringColor_(Color.white)
        .action_({ |lv|
            var idx = lv.selection[0];
            if(idx.notNil) {
                ~removePriceAlert.value(idx);
                ~updateAlertList.value;
            };
        });
    
    layout.add(~alertList);
    window.layout = layout;
    window.front;
};

// Add price alert
~addPriceAlert = { |price, type|
    var alertDict = if(type == 0) {
        ~priceAlerts.high;
    } {
        ~priceAlerts.low;
    };
    
    alertDict.put(price, true);
    ~updateAlertList.value;
};

// Remove price alert
~removePriceAlert = { |idx|
    var alerts = ~priceAlerts.high.keys.asArray ++ ~priceAlerts.low.keys.asArray;
    var price = alerts[idx];
    var type = if(~priceAlerts.high.includesKey(price)) {
        ~priceAlerts.high;
    } {
        ~priceAlerts.low;
    };
    
    type.removeAt(price);
};

// Update alert list
~updateAlertList = {
    var items = [];
    
    ~priceAlerts.high.keys.do { |price|
        items = items.add("Above: " ++ price);
    };
    
    ~priceAlerts.low.keys.do { |price|
        items = items.add("Below: " ++ price);
    };
    
    {
        ~alertList.items = items;
    }.defer;
};

// Check price alerts
~checkAlerts = { |price|
    if(~priceAlerts.active) {
        ~priceAlerts.high.keys.do { |threshold|
            if(price > threshold) {
                ~triggerAlert.value("Price above " ++ threshold, price);
            };
        };
        
        ~priceAlerts.low.keys.do { |threshold|
            if(price < threshold) {
                ~triggerAlert.value("Price below " ++ threshold, price);
            };
        };
    };
};

// Trigger alert
~triggerAlert = { |message, price|
    {
        var alert = Window("Price Alert!", Rect(900, 400, 300, 100));
        var layout = VLayout(
            StaticText()
                .string_(message)
                .align_(\center)
                .stringColor_(Color.red),
            StaticText()
                .string_("Current price: " ++ price)
                .align_(\center)
        );
        
        alert.layout = layout;
        alert.front;
        
        if(~priceAlerts.soundEnabled) {
            {
                SinOsc.ar(440 * Line.kr(1, 2, 0.2)) * EnvGen.kr(Env.perc(0.01, 0.2), doneAction: 2)
            }.play;
        };
        
        fork {
            5.wait;
            alert.close;
        };
    }.defer;
};

// Initialize windows
~addTrendWindow.value;
~addAlertWindow.value;

// Update original OSC handler
~originalEthTxDetails = OSCdef(\ethTxDetails).func;
OSCdef(\ethTxDetails).func = { |msg|
    var etherValue = msg[2].asFloat;
    
    ~originalEthTxDetails.value(msg);
    ~updateTrendAnalysis.value;
    ~checkAlerts.value(etherValue);
};
)