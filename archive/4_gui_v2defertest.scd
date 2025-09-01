// SuperCollider Ethereum Sonification - GUI Components
// Current Date and Time (UTC): 2025-03-01 22:26:45
// Current User's Login: alejoduque

(
// Defer GUI creation to AppClock
{
    var window, transactionCount, valueDisplay, activityMeter;
    
    window = Window("Ethereum Sonification", Rect(100, 100, 400, 300))
        .front;
    
    // Transaction counter
    transactionCount = StaticText(window, Rect(20, 20, 200, 20))
        .string_("Transactions: 0");
    
    // Value display
    valueDisplay = StaticText(window, Rect(20, 50, 200, 20))
        .string_("Last Value: 0 ETH");
    
    // Activity meter
    activityMeter = UserView(window, Rect(20, 80, 360, 100))
        .background_(Color.black)
        .animate_(true)
        .drawFunc_({ |view|
            if(~globalState.notNil and: {~globalState.lastValue.notNil}) {
                Pen.fillColor = Color.green(0.5, 0.5);
                Pen.addRect(Rect(0, 0, 
                    ~globalState.lastValue.linlin(0, 10, 0, view.bounds.width),
                    view.bounds.height
                ));
                Pen.fill;
            };
        });
    
    // Make GUI elements globally accessible
    ~mainWindow = window;
    ~transactionCount = transactionCount;
    ~valueDisplay = valueDisplay;
    ~activityMeter = activityMeter;
    
    window.onClose_({
        ~mainWindow = nil;
        ~transactionCount = nil;
        ~valueDisplay = nil;
        ~activityMeter = nil;
    });
    
    "GUI System loaded.".postln;
}.defer;
)