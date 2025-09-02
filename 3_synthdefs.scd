// SuperCollider Ethereum Sonification - Synth Definitions
// Current Date and Time (UTC): 2025-03-01 20:58:06
// Current User's Login: alejoduque

(
// Wait for server to be ready and create proper group structure
s.waitForBoot({
    // Ensure default group exists
    if(~defaultGroup.isNil or: { ~defaultGroup.isPlaying.not }) {
        ~defaultGroup = Group.new(s, \addToHead);
    };
    s.sync;

    // MERGED CONTROL PARAMETERS - Lawrence English ambient + existing drone/noise controls
    ~globalParams = (
        // === Lawrence English Ambient Controls (Row 1) ===
        masterVolume: 0.3,    // CC 0  - ACTUAL master volume control
        pitchShift: 0.0,      // CC 1  - Frequency shift in semitones (-24 to +24)
        timeDilation: 2.0,    // CC 2  - Stretch/compress time (decay multiplier)
        spectralShift: 1000,  // CC 3  - Filter frequency for spectral shaping
        spatialSpread: 0.0,   // CC 4  - Spatial positioning (-1 to 1)

        // === Ambient Processing (Row 2) ===
        textureDepth: 0.2,    // CC 32 - Granular texture density
        atmosphereMix: 0.4,   // CC 33 - Reverb amount (ambient space)
        memoryFeed: 0.3,      // CC 34 - Delay feedback (memory/echo)
        harmonicRich: 1.0,    // CC 35 - FM ratio (harmonic complexity)
        resonantBody: 0.4,    // CC 36 - Filter resonance (body/formant)

        // === Existing Drone/Noise Controls (Row 3) ===
        masterAmp: 0.7,       // CC 64 - Legacy master amp
        filterCutoff: 0.6,    // CC 65 - Legacy filter
        noiseLevel: 0.1,      // CC 66 - Noise amount
        noiseFilt: 0.5,       // CC 67 - Noise filtering
        droneDepth: 0.3,      // CC 68 - Drone intensity
        droneFade: 2.0,       // CC 69 - Drone envelope
        droneSpace: 0.5,      // CC 70 - Drone spatial
        droneMix: 0.5,        // CC 71 - Drone blend

        // === Flow Controls ===
        flowRate: 0.8,        // Transaction playback rate
        sparsity: 0.2,        // Minimum gap between events
        delayFeedback: 0.3,   // Additional delay control
        transactionInfluence: 0.3  // How much transactions affect parameters
    );

    // Main transaction bell with MIDI control
    SynthDef(\elektronBell, {
        arg freq=440, amp=0.3, 
        atk=0.01, dec=0.3, rel=0.5,
        tone=0.3, res=0.4, pan=0,
        // Bus indices for real-time MIDI control (merged parameter set)
        masterVolBus=(-1), pitchBus=(-1), timeBus=(-1), spectralBus=(-1), spatialBus=(-1),
        textureBus=(-1), atmosphereBus=(-1), memoryBus=(-1), harmonicBus=(-1), resonantBus=(-1),
        // Additional drone/noise control buses
        masterAmpBus=(-1), filterCutoffBus=(-1), noiseLevelBus=(-1), noiseFiltBus=(-1),
        droneDepthBus=(-1), droneFadeBus=(-1), droneSpaceBus=(-1), droneMixBus=(-1),
        // Spatial positioning buses
        spatialXBus=(-1), spatialYBus=(-1), roomSizeBus=(-1), distanceEffectBus=(-1);

        var env, sig, mod, carrier, grains, wet, noise, drone, distance, distanceAmp, quadSig;
        // MIDI bus inputs - Lawrence English ambient style with bus parameter fallbacks
        var masterVol = Select.kr(masterVolBus >= 0, [0.3, In.kr(masterVolBus, 1)]);
        var pitchOffset = Select.kr(pitchBus >= 0, [0.0, In.kr(pitchBus, 1)]);
        var timeStretch = Select.kr(timeBus >= 0, [2.0, In.kr(timeBus, 1)]);
        var spectralFreq = Select.kr(spectralBus >= 0, [1000, In.kr(spectralBus, 1)]);
        var spatialPos = Select.kr(spatialBus >= 0, [0.0, In.kr(spatialBus, 1)]);
        var textureDensity = Select.kr(textureBus >= 0, [0.2, In.kr(textureBus, 1)]);
        var atmosphereLevel = Select.kr(atmosphereBus >= 0, [0.4, In.kr(atmosphereBus, 1)]);
        var memoryFeedback = Select.kr(memoryBus >= 0, [0.3, In.kr(memoryBus, 1)]);
        var harmonicComplexity = Select.kr(harmonicBus >= 0, [1.0, In.kr(harmonicBus, 1)]);
        var filterResonance = Select.kr(resonantBus >= 0, [0.4, In.kr(resonantBus, 1)]);
        
        // Additional drone/noise parameters
        var legacyAmp = Select.kr(masterAmpBus >= 0, [0.7, In.kr(masterAmpBus, 1)]);
        var legacyFilter = Select.kr(filterCutoffBus >= 0, [0.6, In.kr(filterCutoffBus, 1)]);
        var noiseAmount = Select.kr(noiseLevelBus >= 0, [0.1, In.kr(noiseLevelBus, 1)]);
        var noiseFilter = Select.kr(noiseFiltBus >= 0, [0.5, In.kr(noiseFiltBus, 1)]);
        var droneIntensity = Select.kr(droneDepthBus >= 0, [0.3, In.kr(droneDepthBus, 1)]);
        var droneEnvelope = Select.kr(droneFadeBus >= 0, [2.0, In.kr(droneFadeBus, 1)]);
        var droneMix = Select.kr(droneMixBus >= 0, [0.5, In.kr(droneMixBus, 1)]);
        
        // Spatial positioning parameters from spatial GUI
        var spatialX = Select.kr(spatialXBus >= 0, [0.0, In.kr(spatialXBus, 1)]);
        var spatialY = Select.kr(spatialYBus >= 0, [0.0, In.kr(spatialYBus, 1)]);
        var roomSizeParam = Select.kr(roomSizeBus >= 0, [0.8, In.kr(roomSizeBus, 1)]);
        var distanceParam = Select.kr(distanceEffectBus >= 0, [0.5, In.kr(distanceEffectBus, 1)]);
        
        var grainMorph = textureDensity; // Use texture depth for granular morphing
        
        // Apply pitch shift (more audible range for real-time control)
        freq = freq * (pitchOffset.clip(-24, 24) / 12).midiratio; // ±2 octaves for more dramatic effect
        
        // FM Synthesis - more dramatic harmonic complexity for real-time control
        mod = SinOsc.ar(freq * harmonicComplexity.linexp(0.1, 8, 0.5, 4.0)) * 
              (harmonicComplexity.linlin(0.1, 8, 0.05, 0.4)) * freq;
        carrier = SinOsc.ar(freq + mod);
        
        // Long ambient envelope with time dilation
        env = EnvGen.kr(
            Env.new(
                [0, 1, 0.8, 0.3, 0],
                [atk, dec * timeStretch, rel * timeStretch * 2, rel * timeStretch],
                [\sine, -2, -3, -4]
            ),
            doneAction: 2
        );
        
        sig = carrier * env;
        
        // Spectral shaping filter with dramatic range for real-time control
        sig = RLPF.ar(
            sig,
            spectralFreq.clip(80, 8000),    // Wider frequency range for more dramatic effect
            filterResonance.clip(0.1, 0.8)  // More resonance range
        );
        
        // Granular texture processing
        grains = GrainIn.ar(
            2,
            Dust.kr(textureDensity.linexp(0, 1, 0.5, 25)),
            grainMorph.linexp(0, 1, 0.02, 0.4),
            sig,
            spatialPos
        );
        
        // Morphing between clean and granular
        sig = XFade2.ar(sig, grains, grainMorph.linlin(0, 1, -1, 1));
        
        // Memory/echo delay with feedback
        wet = DelayC.ar(
            sig,
            2.0,
            LFNoise2.kr(0.05).range(0.1, 1.8),
            memoryFeedback
        );
        sig = sig + wet;
        
        // Atmospheric reverb with spatial room size
        sig = FreeVerb2.ar(
            sig[0], sig[1],
            atmosphereLevel,
            roomSizeParam.clip(0.1, 0.99),  // Room size from spatial GUI
            0.3   // Damping for ambient feel
        );
        
        // Add noise layer (controlled by existing noise parameters)
        noise = PinkNoise.ar() * noiseAmount;
        noise = LPF.ar(noise, noiseFilter.linexp(0, 1, 200, 8000));
        
        // Add drone layer (controlled by existing drone parameters)
        drone = SinOsc.ar(freq * 0.5) * droneIntensity;
        drone = drone * EnvGen.kr(Env.asr(droneEnvelope, 1, droneEnvelope));
        
        // Mix all layers
        sig = sig + (noise * 0.3) + (drone * droneMix);
        
        // Apply legacy filter on top of spectral filter
        sig = LPF.ar(sig, legacyFilter.linexp(0, 1, 300, 6000));
        
        // Calculate distance-based amplitude scaling
        distance = (spatialX.squared + spatialY.squared).sqrt;
        distanceAmp = 1 - (distance * distanceParam * 0.5);
        
        // Combined volume control with distance effect
        sig = sig * (amp * (masterVol.clip(0.01, 1).squared) * (legacyAmp.clip(0.01, 1)) * distanceAmp.clip(0.1, 1));
        
        // Quadraphonic spatial positioning
        quadSig = PanAz.ar(
            4,                    // 4 channels for quad
            sig.sum,              // Mono sum for panning
            spatialX.atan2(spatialY) / pi,  // Angle from X,Y coordinates
            1,                    // Amplitude
            2,                    // Speaker array radius
            0.5                   // Orientation
        );
        
        Out.ar(0, quadSig);
    }).add;

    // Create control buses for MIDI - ensure proper initialization order
    ~buses = ();  // Reset buses to avoid conflicts
    
    "Creating control buses...".postln;
    ~globalParams.keysValuesDo { |param, val|
        ~buses[param] = Bus.control(s, 1);
        ~buses[param].set(val);
        "Bus created: % = % (index: %)".format(param, val, ~buses[param].index).postln;
    };
    
    // Add spatial control buses for ambient sounds
    ~buses.spatialX = Bus.control(s, 1).set(0.0);
    ~buses.spatialY = Bus.control(s, 1).set(0.0);
    ~buses.roomSize = Bus.control(s, 1).set(0.8);
    ~buses.distanceEffect = Bus.control(s, 1).set(0.5);
    
    // Print final bus setup for debugging
    "".postln;
    "=== CONTROL BUS SETUP COMPLETE ===".postln;
    "Total buses created: %".format(~buses.size).postln;
    ~buses.keysValuesDo { |name, bus|
        "  % -> Bus[%] = %".format(name, bus.index, bus.getSynchronous.round(0.001)).postln;
    };
    "================================".postln;
    
    // Wait for SynthDef to be added to server
    s.sync;

    // Note: OSC handlers are defined in 6_osc_handlers.scd to avoid conflicts

    "Synth Definitions loaded - Lawrence English ambient style".postln;
    
    // Print ambient control map
    "LAWRENCE ENGLISH AMBIENT CONTROL MAP:".postln;
    "Row 1 - Core Performance:".postln;
    "  CC 0  -> Master Volume (actual volume!)".postln;
    "  CC 1  -> Pitch Shift (±2 octaves for freq blending)".postln;
    "  CC 2  -> Time Dilation (envelope stretch)".postln;
    "  CC 3  -> Spectral Shift (filter sweep)".postln;
    "  CC 4  -> Spatial Spread (quad positioning)".postln;
    "\nRow 2 - Ambient Processing:".postln;
    "  CC 32 -> Texture Depth (granular density)".postln;
    "  CC 33 -> Atmosphere Mix (reverb space)".postln;
    "  CC 34 -> Memory Feed (delay feedback)".postln;
    "  CC 35 -> Harmonic Rich (FM complexity)".postln;
    "  CC 36 -> Resonant Body (filter resonance)".postln;
});
)