// SuperCollider Ethereum Sonification - GUI System
// Current Date and Time (UTC): 2025-03-01 05:23:28
// Current User's Login: alejoduque

(
// Close any existing windows
if(~mainWindow.notNil) { ~mainWindow.close };
if(~transactionWindow.notNil) { ~transactionWindow.close };

// Create main window
~mainWindow = Window("Ethereum Sonification", Rect(100, 100, 800, 600))
    .front
    .alwaysOnTop_(true);

~mainWindow.view.decorator = FlowLayout(~mainWindow.bounds, Point(10, 10), Point(10, 5));

// Transaction visualization
~visualizer = UserView(~mainWindow, 780@300)
    .background_(Color.black)
    .animate_(true)
    .drawFunc_({ |view|
        var now = SystemClock.seconds;
        
        // Draw background grid
        Pen.strokeColor = Color.gray(0.3);
        20.do { |i|
            var x = (i/19) * view.bounds.width;
            Pen.line(Point(x, 0), Point(x, view.bounds.height));
            Pen.stroke;
        };
        
        // Draw transactions
        if(~transactions.notNil) {
            ~transactions.do { |tx|
                var age = now - tx[\time];
                var alpha = 1.0 - (age/10.0); // Fade over 10 seconds
                
                if(alpha > 0) {
                    var value = tx[\value].linlin(0, 10, 10, view.bounds.height - 10);
                    var x = tx[\x];
                    
                    Pen.fillColor = Color.new(1, 0.7, 0, alpha);
                    Pen.addOval(Rect(x-5, view.bounds.height - value - 5, 10, 10));
                    Pen.fill;
                };
            };
        };
    });

// Initialize transaction array
~transactions = [];

// Add new transaction
~addTransaction = { |value|
    var tx = (
        time: SystemClock.seconds,
        value: value,
        x: 780.rand
    );
    ~transactions = ~transactions.select { |tx|
        (SystemClock.seconds - tx[\time]) < 10
    };
    ~transactions = ~transactions.add(tx);
};

// Status display
StaticText(~mainWindow, 780@30)
    .string_("Ethereum Mainnet Transaction Monitor")
    .align_(\center)
    .background_(Color.grey(0.9))
    .font_(Font("Helvetica", 18));

// Transaction count
~transactionCount = StaticText(~mainWindow, 380@20)
    .string_("Transactions: 0")
    .align_(\center);

~valueDisplay = StaticText(~mainWindow, 380@20)
    .string_("Last Value: 0 ETH")
    .align_(\center);

// Control section
~controlsView = View(~mainWindow, 780@200);
~controlsView.decorator = FlowLayout(~controlsView.bounds, Point(10, 10), Point(10, 5));

// Add basic controls
[
    [\masterVolume, "Master Volume", 0.7],
    [\tempo, "Tempo", 1.0],
    [\pitch, "Pitch", 0.5],
    [\decay, "Decay", 0.3]
].do { |ctrl|
    var name = ctrl[0];
    var label = ctrl[1];
    var default = ctrl[2];
    
    StaticText(~controlsView, 180@20).string_(label);
    Slider(~controlsView, 180@20)
        .value_(default)
        .action_({ |sl|
            ~beatParams[name] = sl.value;
            if(name == \masterVolume) { ~beatParams.masterAmp = sl.value };
        });
};

// Add OSC handler for transaction visualization
OSCdef(\txVisualizer, { |msg|
    var value = msg[2].asFloat;
    
    {
        ~addTransaction.value(value);
        ~transactionCount.string = "Transactions: %".format(~globalState.transactionCount);
        ~valueDisplay.string = "Last Value: % ETH".format(value.round(0.001));
    }.defer;
}, '/tx');

// Start animation
AppClock.play({
    ~visualizer.refresh;
    0.04; // 25 fps
});

"GUI System loaded.".postln;
)