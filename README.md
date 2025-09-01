# Ethereum Transaction Sonification System
Current Version: 2024.03.01
Author: alejoduque

## Overview
A SuperCollider-based system that transforms Ethereum blockchain transactions into an interactive sound environment. The system uses the Faderfox LC2 MIDI controller for real-time manipulation of the sonification parameters.

## Requirements
- SuperCollider 3.13.0 or higher
- Python 3.8+ (for the transaction data fetching)
- Faderfox LC2 MIDI Controller
- E-MU XMidi1X1 Tab MIDI interface

## File Structure
```
eth_sonification/
├── main.scd               # Main loader and system initialization
├── 1_init.scd            # System initialization
├── 2_midi_control.scd    # MIDI mapping and control system
├── 3_synthdefs.scd       # Sound synthesizer definitions
├── 4_gui.scd             # Graphical user interface
├── 5_beat_engine.scd     # Rhythmic engine
├── 6_osc_handlers.scd    # OSC communication handlers
├── 7_trend_analysis.scd  # Transaction trend analysis
└── 8_transaction_buffer.scd # Transaction data buffering
```

## Quick Start
1. Connect your Faderfox LC2 MIDI controller
2. Launch SuperCollider
3. Open `main.scd`
4. Execute the following code:
```supercollider
s.boot;  // Boot the server
~loadEthereumSonification.value;  // Load and initialize the system
```

## MIDI Controller Layout (Faderfox LC2)

### Channel A (Transaction Sounds)
- Faders 16-23:
  - 16: Main Volume
  - 17: Bell Tone
  - 18: Bell Decay
  - 19: Bell Resonance
  - 20: FM Index
  - 21: FM Feedback
  - 22: Transaction Amplitude
  - 23: Master Filter

- Encoders 0-7:
  - 0: Spatial Spread
  - 1: Bell Attack
  - 2: Delay Time
  - 3: Delay Feedback
  - 4: Modulation Depth
  - 5: Modulation Rate
  - 6: Reverb Mix
  - 7: Reverb Time

### Channel B (Drones & Atmosphere)
- Faders 24-31:
  - 24: Drone Volume
  - 25: Drone Tone
  - 26: Drone Resonance
  - 27: Drone Modulation
  - 28: Noise Level
  - 29: Noise Color
  - 30: Atmosphere Mix
  - 31: Drone Spatial

- Encoders 8-15:
  - 8: Drone Depth
  - 9: Drone Rate
  - 10: Drone Fade
  - 11: Drone Harmonics
  - 12: Noise LPF
  - 13: Noise HPF
  - 14: Noise Q
  - 15: Noise Modulation

### Channel C (Rhythm & Beats)
- Faders 32-39:
  - 32: Beat Volume
  - 33: Beat Density
  - 34: Beat Decay
  - 35: Swing Amount
  - 36: Beat Filter
  - 37: Beat Resonance
  - 38: Beat Drive
  - 39: Beat Spatial

- Encoders 16-23:
  - 16: Tempo
  - 17: Division
  - 18: Probability
  - 19: Pattern Variation
  - 20: Shuffle Amount
  - 21: Accent Level
  - 22: Groove Amount
  - 23: Beat Shift

### Channel D (Effects & Response)
- Faders 40-47:
  - 40: Responsiveness
  - 41: Value Scaling
  - 42: Effects Mix
  - 43: Effects Depth
  - 44: Filter Envelope
  - 45: Modulation Amount
  - 46: Feedback
  - 47: Complexity

- Encoders 24-31:
  - 24: Sensitivity
  - 25: Threshold
  - 26: Range
  - 27: Response Curve
  - 28: Attack Time
  - 29: Release Time
  - 30: Scale Selection
  - 31: Random Variation

## Troubleshooting

### MIDI Connection Issues
1. Check MIDI connections in SuperCollider:
```supercollider
MIDIClient.init;
MIDIIn.connectAll;
MIDIFunc.trace(true);  // Enable MIDI monitoring
```

2. Verify controller is recognized:
```supercollider
MIDIClient.sources;  // Should list your Faderfox LC2
```

### No Sound
1. Check server status:
```supercollider
s.boot;  // Make sure server is running
s.meter;  // Check levels
```

2. Verify main volume:
- Adjust fader 16 on Channel A
- Check `~midiSystem.params.mainVolume` value

### Transaction Data Issues
1. Check OSC connection:
```supercollider
NetAddr.langPort;  // Verify OSC port
```

2. Monitor incoming transactions:
```supercollider
OSCFunc.trace(true);  // Enable OSC monitoring
```

## Support
For issues and questions:
- Check the SuperCollider forum
- Submit issues to the project repository
- Contact: [Your Contact Information]

## License
[Your License Information]