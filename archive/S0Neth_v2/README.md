# Ethereum Sonification System
**Current Date and Time (UTC):** 2025-03-01 23:00:32  
**Current User's Login:** alejoduque  
**Version:** 1.0.0

## Overview
This SuperCollider-based system translates Ethereum blockchain transactions into real-time sound and visual feedback. It combines transaction data analysis, MIDI control, and interactive visualization to create an immersive audio-visual experience of blockchain activity.

## System Requirements
- SuperCollider 3.13.0 or higher
- MIDI controller (optional, tested with Faderfox LC2)
- External audio interface recommended
- macOS, Linux, or Windows

## File Structure
```
├── main_loader.scd         # Main system loader
├── 0_init.scd             # System initialization
├── 1_server_config.scd    # Audio server configuration
├── 2_synthdefs.scd        # Sound synthesizer definitions
├── 3_midi_control.scd     # MIDI mapping and controls
├── 4_gui.scd             # Graphical user interface
├── 5_beat_engine.scd      # Rhythmic engine
├── 6_osc_handlers.scd     # OSC message handling
├── 7_trend_analysis.scd   # Transaction trend analysis
├── 8_transaction_buffer.scd # Transaction management
└── test_system.scd        # System testing suite
```

## Installation
1. Clone the repository to your local machine
2. Open SuperCollider
3. Navigate to the project directory
4. Open and run `main_loader.scd`

## Component Descriptions

### 1. Initialization (0_init.scd)
- Global state management
- Component configuration
- System parameters

### 2. Server Configuration (1_server_config.scd)
- Audio server setup
- Bus routing
- Resource allocation

### 3. Sound Definitions (2_synthdefs.scd)
- Transaction sonification
- Beat synthesis
- Effect processing
- Master output

### 4. MIDI Control (3_midi_control.scd)
- MIDI device configuration
- Control mapping
- Real-time parameter adjustment

### 5. GUI (4_gui.scd)
- Transaction visualization
- System status display
- Real-time updates

### 6. Beat Engine (5_beat_engine.scd)
- Rhythm generation
- Transaction-influenced patterns
- Tempo control

### 7. OSC Handlers (6_osc_handlers.scd)
- Transaction message processing
- Event routing
- System communication

### 8. Trend Analysis (7_trend_analysis.scd)
- Transaction pattern analysis
- Moving averages
- Trend detection

### 9. Transaction Buffer (8_transaction_buffer.scd)
- Transaction history
- Statistical analysis
- Data management

## Usage

### Starting the System
```supercollider
// Run the main loader
(
var basePath = thisProcess.nowExecutingPath.dirname;
(basePath +/+ "main_loader.scd").load;
)
```

### Testing
```supercollider
// Run system tests
(
var basePath = thisProcess.nowExecutingPath.dirname;
(basePath +/+ "test_system.scd").load;
)
```

### MIDI Control Mapping
The system is configured for the Faderfox LC2 controller:

Channel 14, First Row:
- CC 0: Volume
- CC 1: FM Ratio
- CC 2: Grain Size
- CC 3: Filter Freq
- CC 4: Pitch Offset

Channel 14, Second Row:
- CC 32: FM Depth
- CC 33: Grain Density
- CC 34: Decay Time
- CC 35: Delay Mix
- CC 36: Reverb Mix

Channel 12:
- CC 0: Playback Rate
- CC 1: Minimum Gap

## Troubleshooting

### Common Issues
1. **Server fails to boot**
   - Check audio device settings
   - Ensure no other applications are using the audio interface
   - Try increasing server memory in 1_server_config.scd

2. **MIDI controller not recognized**
   - Check MIDI device connections
   - Verify MIDI port settings in 3_midi_control.scd
   - Restart SuperCollider

3. **GUI not displaying**
   - Ensure Qt is properly installed
   - Check screen bounds settings
   - Run on AppClock

### System Verification
Use the built-in verification system:
```supercollider
// Check system status
~checkServerStatus.value;

// Test audio
~testSound.value;

// Test transaction processing
~testTransaction.value;
```

## Development

### Adding New Components
1. Create new component file
2. Add to initialization sequence in main_loader.scd
3. Update component dependencies
4. Add verification tests
5. Update README.md

### Modifying Existing Components
1. Check component dependencies
2. Update verification tests
3. Test system integration
4. Update documentation

## License
MIT License - See LICENSE file for details

## Contributors
- Current maintainer: alejoduque

## Version History
- 1.0.0 (2025-03-01)
  - Initial release
  - Basic transaction sonification
  - MIDI control support
  - Real-time visualization