(
// Initialize GUI-related variables
~knobViews = ();
~controlLabels = ();
~displayLabels = (
    volume: "Volume",
    fmratio: "FM Ratio",
    grainsize: "Grain Size",
    filterfreq: "Filter Freq",
    pitchoffset: "Pitch Offset",
    fmdepth: "FM Depth",
    graindensity: "Grain Density",
    decay: "Decay",
    delaymix: "Delay Mix",
    reverbmix: "Reverb Mix"
);

// Define the GUI window
~mainWindow = Window("SuperCollider Controller", Rect(100, 100, 600, 400));

// Create a view to hold the controls
~mainView = VLayoutView(~mainWindow.view.bounds);
~mainWindow.view.addView(~mainView);

// Function to create a knob and label
var createKnob = { |name|
    var spec = ~controlSpecs[name];
    var currentValue = ~controlValues[name];
    var knob, label, panel;

    // Panel to hold knob and label
    panel = HLayoutView(Rect(0, 0, 200, 50));

    // Create Knob
    knob = Knob(panel, Rect(0, 0, 50, 50));
    knob.value_(spec.unmap(currentValue)); // Set initial value
    knob.valueSpec = spec; // Set the spec
    ~knobViews[name] = knob; // Store knob for later access

    // Create Label
    label = StaticText(panel, Rect(0, 0, 140, 20));
    label.align = \center;
    label.string = (~displayLabels[name] ? name.asString.capitalize) ++ ": " ++ currentValue.round(0.001);
    ~controlLabels[name] = label;

    // Add views to the panel
    panel.addView(knob);
    panel.addView(label);

    // Add action to the knob
    knob.action = {
        var newValue = spec.map(knob.value);
        ~controlBuses[name].set(newValue);
        ~controlValues[name] = newValue;
        label.string = (~displayLabels[name] ? name.asString.capitalize) ++ ": " ++ newValue.round(0.001);

        // Update any active synths
        if(~currentSynths.notNil) {
            ~currentSynths.do { |synth|
                if(synth.notNil and: { synth.isPlaying }) {
                    synth.set(
                        name, newValue,  // Direct parameter setting
                        (name ++ "Bus").asSymbol, ~controlBuses[name].index  // Bus setting
                    );
                };
            };
        };
    };

    panel // Return the panel containing the knob and label
};

// Create knobs for each control
~controlSpecs.keys.do { |name|
    var knobGroup = createKnob.(name);
    ~mainView.addView(knobGroup);
};

// Show the window
~mainWindow.front;

// Add a close function
~mainWindow.onClose = {
    MIDIdef.freeAll;
    ~knobViews = ();
    ~controlLabels = ();
    ~mainWindow = nil;
    ~mainView = nil;
    ~displayLabels = ();
};
)
