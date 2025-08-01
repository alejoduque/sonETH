
``
                                  :::.                                                    
                                :+++***++:..                                              
                      :-=+=..:-=+**=======---:                                            
                     -+++****+====-::-=====-::. ..   ..       ::                          
                    .=++++++=::----------::-::::::--------===--:.:::::.                   
                   :--==+++=-::----------======----------:-===-:::::::.                   
                   ::--==+++-----=+++=+++++====----======--==------::                     
                  ::::-====+++++++*************+==========---------::..                   
                 ..:::---==++*****************+++++++++=------------:::::..               
                ....:::-=+**********************++++++=--==========--:.....               
                 ..:::-++*********+**************+++++++--+***++++==:      .::..          
                :=+*+=+++****++==+++*+++++++***+++++++++***********+=. .::-====-::--:     
             .:-=++=====+++*++====++++++++++++++++++=+++*************+=======++++==--.    
           .--==-----=====++=============+=+++=====++++****************+=+=========--:.   
     . .  :--====------=======--==========+++=====++++****+*****+****++===-----===
  :::::::---====----------::::::-----========++++++++++***++++++++===--:::::-----.    
   ..::::::..:::::---::::::::::...::::::::-----=++++++++++****+++++++===-:::::::::---:   
      .::::.....:::::::::::................:::::=++++++++++*****++++++=====---:::::---::. 
         ......   .........     ...............::=+==++++++++++++++============-----::...:
                                    ........::---===-===============------=---:::::::::...
                                    .......................::::::::---------:.   ..       
                                            ....................::::::--:::::.            
                                                             ...........                  
                                                                                          


# Ethereum Sonification System
Current Date and Time (UTC): 2025-03-03 02:54:37
Current User's Login: alejoduque

## Overview
SuperCollider-based system for real-time sonification of Ethereum blockchain data through MIDI control and GUI interface.

## System Requirements
- SuperCollider 3.13.0 or higher
- MIDI Controller (tested with E-MU XMidi1X1)
- Git (for version control)
- Operating System: macOS, Linux, or Windows

## Components & Versions

1. `loader.scd` (v5.0.3)
   - Main system loader
   - Manages component initialization sequence
   - Provides status reporting

2. `1_server_config.scd` (v3.2.1)
   - Server configuration
   - Audio bus setup
   - Default sample rate: 48000
   - Block size: 512

3. `2_synthdefs.scd` (v8.4.2)
   - Contains all synth definitions
   - Includes: elektronBell, beatSynth

4. `3_midi_control.scd` (v17.3.5)
   - MIDI control system
   - Channel: 14
   - CC mappings for all parameters
   - Automatic MIDI device detection

5. `4_gui.scd` (v47.2.8)
   - GUI interface with real-time updates
   - Parameter controls
   - Status indicators
   - Performance counters

6. `5_beat_engine.scd` (v12.1.4)
   - Beat engine (default: 120 BPM)
   - Timing coordination
   - Beat pattern management

7. `6_osc_handlers.scd` (v9.3.2)
   - OSC message handlers
   - Port: 57120
   - Transaction sonification handlers
   - Test function: ~testTransaction

8. `7_trend_analysis.scd` (v4.1.7)
   - Real-time trend analysis
   - Market data processing
   - Pattern detection

9. `8_transaction_buffer.scd` (v6.2.3)
   - 9-slot transaction buffer
   - FIFO queue implementation
   - Overflow protection

10. `9_main_interface.scd` (v7.4.1)
    - Debug interface
    - System status monitoring
    - OSC testing (~checkOSC)

## Installation

1. Clone this repository:
\`\`\`bash
git clone https://github.com/alejoduque/sonETH.git
cd sonETH
\`\`\`

2. Open SuperCollider and load the system:
   - Open \`loader.scd\`
   - Execute the entire file (Cmd/Ctrl + Return)

## MIDI Configuration

The system uses the following CC mappings:
- CC 0: Volume (0-1)
- CC 1: FM Ratio (0.5-4)
- CC 2: Grain Size (0.01-0.5)
- CC 3: Filter Frequency (200-5000Hz)
- CC 4: Pitch Offset (-12 to +12)
- CC 32: FM Depth (0-1)
- CC 33: Grain Density (5-50)
- CC 34: Decay (0.5-3)
- CC 35: Delay Mix (0-1)
- CC 36: Reverb Mix (0-1)

## Troubleshooting

### Common Issues

1. **MIDI Not Detected**
   - Check MIDI device connections
   - Verify MIDI device is powered on
   - Confirm channel setting (should be 14)

2. **GUI Not Responding**
   - Check Server status
   - Restart SuperCollider
   - Execute loader.scd again

3. **Audio Issues**
   - Verify audio device settings
   - Check Server status
   - Confirm block size and sample rate

4. **OSC Communication Fails**
   - Verify port 57120 is available
   - Check network connections
   - Use ~checkOSC to test

### Error Messages

If you see:
\`\`\`
Failed components:
- 3_midi_control.scd
- 4_gui.scd
\`\`\`
But components are working, check:
- \`~midiControl\` global variable exists
- \`~mainWindow\` global variable exists

## Testing

1. Test MIDI:
   - Move any knob on your MIDI controller
   - Check console for "MIDI CC:" messages

2. Test GUI:
   - All status lights should be green
   - Counters should update
   - Knobs should respond to MIDI

3. Test OSC:
   - Run: ~testTransaction.value;
   - Check for sonification response

## Version History

Last stable version: 2025-03-03 02:54:37 UTC
- Fixed MIDI and GUI loader detection
- All components initializing correctly
- Full MIDI-GUI synchronization
- Stable OSC communication

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review console messages
3. Create an issue on GitHub

## License

[Add your license information here]
