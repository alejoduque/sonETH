// SuperCollider Ethereum Sonification - GUI Components
// Current Date and Time (UTC): 2025-03-02 01:07:52
// Current User's Login: alejoduque
// Initialization Sequence: 5 of 9

(
{
    var window, mainView, controlView;
    var fonts;
    
    try {
        fonts = (
            title: Font("Helvetica Bold", 14),
            normal: Font("Helvetica", 12),
            mono: Font("Monaco", 11)
        );
        
        window = Window("Ethereum Sonification", Rect(100, 100, 800, 600))
            .front
            .onClose_({
                try {
                    ~mainWindow = nil;
                    ~valueDisplay = nil;
                    ~activityMeter = nil;
                    "GUI resources freed.".postln;
                } { |err|
                    "GUI cleanup error: %".format(err.asString).error;
                };
            });
        
        mainView = View(window, Rect(0, 0, 800, 300))
            .layout_(VLayout(
                StaticText().string_("Transaction Monitor").font_(fonts.title),
                
                ~valueDisplay = StaticText()
                    .string_("Last Value: 0 ETH")
                    .font_(fonts.normal),
                    
                StaticText()
                    .string_("Server Status")
                    .font_(fonts.title),
                    
                UserView()
                    .background_(Color.grey(0.9))
                    .minHeight_(80)
                    .drawFunc_({ |view|
                        var status = s !? {(
                            cpu: s.avgCPU.asFloat,
                            peak: s.peakCPU.asFloat,
                            synths: s.numSynths
                        )} ? (cpu: 0, peak: 0, synths: 0);
                        
                        Pen.stringLeftJustIn(
                            "CPU: % % (Peak: % %)\nActive Synths: %"
                            .format(
                                status.cpu.round(0.1), "%",
                                status.peak.round(0.1), "%",
                                status.synths
                            ),
                            view.bounds,
                            fonts.mono,
                            Color.black
                        );
                    }),
                    
                StaticText()
                    .string_("Activity")
                    .font_(fonts.title),
                    
                ~activityMeter = UserView()
                    .background_(Color.grey(0.95))
                    .minHeight_(80)
                    .drawFunc_({ |view|
                        var value = ~globalState !? {~globalState.lastValue.asFloat} ? 0;
                        var normValue = value.linlin(0, 10, 0, view.bounds.width);
                        
                        Pen.fillColor = Color.grey(0.9);
                        Pen.fillRect(view.bounds);
                        
                        Pen.fillColor = Color.new(0.2, 0.7, 0.5);
                        Pen.fillRect(Rect(0, 0, normValue, view.bounds.height));
                        
                        Pen.stringCenteredIn(
                            "%.3f ETH".format(value),
                            view.bounds,
                            fonts.mono,
                            Color.black
                        );
                    })
            ));
            
        controlView = View(window, Rect(0, 300, 800, 300))
            .layout_(VLayout(
                StaticText()
                    .string_("Controls")
                    .font_(fonts.title),
                    
                HLayout(
                    StaticText()
                        .string_("Master Volume:")
                        .font_(fonts.normal),
                        
                    Slider()
                        .value_(~audioParams !? {~audioParams.masterVolume} ? 0.5)
                        .action_({ |sl|
                            ~controlBuses !? {
                                ~controlBuses.volume.set(sl.value);
                            };
                        })
                )
            ));
            
        // Update routine
        Routine({
            while { window.isClosed.not } {
                { window.refresh }.defer;
                0.1.wait;
            };
        }).play(AppClock);
        
        ~mainWindow = window;
        
        "GUI System loaded successfully.".postln;
        
    } { |err|
        "GUI creation error: %".format(err.asString).error;
    };
}.defer;
)