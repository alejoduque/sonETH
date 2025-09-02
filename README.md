```
  ____         _   _ _____ _____ _   _ 
 / ___|  ____ | \ | | ____|_   _| | | |
 \___ \ / _//\|  \| |  _|   | | | |_| |
  ___) | (//) | |\  | |___  | | |  _  |
 |____/ \//__/|_| \_|_____| |_| |_| |_|
```

# SøNeth: Ethereum Blockchain Sonification System
## Sistema de Sonificación de la Blockchain de Ethereum

**Version:** 2.0 - Enhanced Real-time Control  
**Author:** alejoduque  
**Aesthetic:** Lawrence English Ambient / Elektron-style Performance

---

## English

### Overview
A SuperCollider-based real-time sonification system that transforms Ethereum blockchain transactions into ambient elektron-style soundscapes. Features a 4-row oscilloscope-style GUI with expanded parameter ranges for dramatic real-time performance control in the Lawrence English ambient aesthetic.

### System Architecture
- **Real-time blockchain data**: Python web3 integration fetches live Ethereum transactions
- **Spatial audio**: 4-channel simulation with binaural headphone processing
- **MIDI control**: Faderfox LC2 controller integration for live performance
- **GUI control**: Enhanced oscilloscope-style interface with 20 real-time parameters
- **Ambient processing**: Granular synthesis, spectral filtering, atmospheric reverb

### Quick Start
1. **Launch SuperCollider** and run:
   ```supercollider
   "start_sonification.scd".load;
   ```

2. **Start Python Ethereum connector**:
   ```bash
   cd eth_sonification
   source venv/bin/activate
   python eth_sonify.py
   ```

3. **Configure spatial mode**:
   ```supercollider
   ~setSpatialMode.(\headphones);  // For headphone development
   ~setSpatialMode.(\quad);        // For 4-channel monitors
   ```

### GUI Control Parameters

#### Row 1: Core Performance (Lawrence English Ambient)
- **Master Volume** (CC 0): Actual volume control (0.01-1.0)
- **Pitch Shift** (CC 1): Frequency shift ±2 octaves (-24 to +24 semitones)
- **Time Dilation** (CC 2): Envelope time stretch (0.5-6x)
- **Spectral Shift** (CC 3): Filter sweep (80-8000 Hz)
- **Spatial Spread** (CC 4): Quad positioning (-1 to +1)

#### Row 2: Ambient Processing
- **Texture Depth** (CC 32): Granular density (0-0.6)
- **Atmosphere Mix** (CC 33): Reverb amount (0-0.9)
- **Memory Feed** (CC 34): Delay feedback (0-0.8)
- **Harmonic Rich** (CC 35): FM complexity (0.1-8)
- **Resonant Body** (CC 36): Filter resonance (0.1-0.8)

#### Row 3: Drone/Noise Controls
- **Master Amp** (CC 64): Legacy master amplitude
- **Filter Cutoff** (CC 65): Legacy filter control
- **Noise Level** (CC 66): Noise amount
- **Noise Filt** (CC 67): Noise filtering
- **Drone Depth** (CC 68): Drone intensity

#### Row 4: Additional Controls
- **Drone Fade** (CC 69): Drone envelope time
- **Drone Space** (CC 70): Drone spatial positioning
- **Drone Mix** (CC 71): Drone blend amount
- **Delay Feedback** (CC 72): Additional delay control
- **Transaction Influence** (CC 73): How much transactions affect parameters

### File Structure
```
SøNeth/
├── start_sonification.scd      # Main system launcher
├── 1_server_config.scd         # Server config and control buses
├── 2_midi_control.scd          # MIDI controller mapping
├── 3_synthdefs.scd             # Enhanced SynthDefs with real-time control
├── 4_gui.scd                   # 4-row oscilloscope GUI
├── 5_beat_engine.scd           # Beat engine with bus connections
├── 6_osc_handlers.scd          # Transaction OSC handling
├── 7_trend_analysis.scd        # Transaction trend analysis
├── 8_transaction_buffer.scd    # Transaction management
├── 9_spatial_headphone_sim.scd # 4-channel spatial audio
├── eth_sonify.py               # Python Ethereum connector
├── archive/                    # Old versions and backups
└── README.md                   # This file
```

### Technical Features
- **Bus-connected synths**: Every transaction and beat synth connects to all control buses
- **Expanded parameter ranges**: ±2 octave pitch, 80-8000Hz filters, dramatic time stretching
- **Lawrence English aesthetic**: Long envelopes, granular processing, atmospheric reverb
- **Spatial audio**: Quadraphonic simulation with ITD/ILD binaural processing
- **Real-time responsiveness**: Immediate parameter changes affect all active sounds

---

## Español

### Descripción General
Sistema de sonificación en tiempo real basado en SuperCollider que transforma las transacciones de la blockchain de Ethereum en paisajes sonoros ambient estilo elektron. Incluye una GUI estilo osciloscopio de 4 filas con rangos de parámetros expandidos para control dramático en tiempo real con estética ambient de Lawrence English.

### Arquitectura del Sistema
- **Datos blockchain en tiempo real**: Integración Python web3 obtiene transacciones Ethereum en vivo
- **Audio espacial**: Simulación 4 canales con procesamiento binaural para auriculares
- **Control MIDI**: Integración controlador Faderfox LC2 para performance en vivo
- **Control GUI**: Interfaz mejorada estilo osciloscopio con 20 parámetros en tiempo real
- **Procesamiento ambient**: Síntesis granular, filtrado espectral, reverb atmosférico

### Inicio Rápido
1. **Iniciar SuperCollider** y ejecutar:
   ```supercollider
   "start_sonification.scd".load;
   ```

2. **Iniciar conector Python Ethereum**:
   ```bash
   cd eth_sonification
   source venv/bin/activate
   python eth_sonify.py
   ```

3. **Configurar modo espacial**:
   ```supercollider
   ~setSpatialMode.(\headphones);  // Para desarrollo con auriculares
   ~setSpatialMode.(\quad);        // Para monitores 4 canales
   ```

### Parámetros de Control GUI

#### Fila 1: Control Principal (Ambient Lawrence English)
- **Master Volume** (CC 0): Control volumen real (0.01-1.0)
- **Pitch Shift** (CC 1): Cambio frecuencia ±2 octavas (-24 a +24 semitonos)
- **Time Dilation** (CC 2): Estiramiento temporal envelope (0.5-6x)
- **Spectral Shift** (CC 3): Barrido filtro (80-8000 Hz)
- **Spatial Spread** (CC 4): Posicionamiento cuadrafónico (-1 a +1)

#### Fila 2: Procesamiento Ambient
- **Texture Depth** (CC 32): Densidad granular (0-0.6)
- **Atmosphere Mix** (CC 33): Cantidad reverb (0-0.9)
- **Memory Feed** (CC 34): Realimentación delay (0-0.8)
- **Harmonic Rich** (CC 35): Complejidad FM (0.1-8)
- **Resonant Body** (CC 36): Resonancia filtro (0.1-0.8)

#### Fila 3: Controles Drone/Ruido
- **Master Amp** (CC 64): Amplitud master heredada
- **Filter Cutoff** (CC 65): Control filtro heredado
- **Noise Level** (CC 66): Cantidad ruido
- **Noise Filt** (CC 67): Filtrado ruido
- **Drone Depth** (CC 68): Intensidad drone

#### Fila 4: Controles Adicionales
- **Drone Fade** (CC 69): Tiempo envelope drone
- **Drone Space** (CC 70): Posicionamiento espacial drone
- **Drone Mix** (CC 71): Cantidad mezcla drone
- **Delay Feedback** (CC 72): Control delay adicional
- **Transaction Influence** (CC 73): Cuánto afectan transacciones a parámetros

### Características Técnicas
- **Sintetizadores conectados por bus**: Cada transacción y beat se conecta a todos los buses de control
- **Rangos de parámetros expandidos**: ±2 octavas pitch, filtros 80-8000Hz, estiramiento temporal dramático
- **Estética Lawrence English**: Envelopes largos, procesamiento granular, reverb atmosférico
- **Audio espacial**: Simulación cuadrafónica con procesamiento binaural ITD/ILD
- **Respuesta en tiempo real**: Cambios inmediatos de parámetros afectan todos los sonidos activos

### Resolución de Problemas / Troubleshooting

#### Sin Sonido / No Sound
1. Verificar servidor / Check server:
   ```supercollider
   s.boot;  // Iniciar servidor / Boot server
   s.meter; // Verificar niveles / Check levels
   ```

2. Probar audio / Test audio:
   ```supercollider
   ~testSound.value;  // Sonido de prueba / Test sound
   ```

#### Problemas MIDI / MIDI Issues
1. Inicializar MIDI / Initialize MIDI:
   ```supercollider
   MIDIClient.init;
   MIDIIn.connectAll;
   ```

2. Verificar controlador / Check controller:
   ```supercollider
   MIDIClient.sources;  // Listar dispositivos / List devices
   ```

#### Conexión Blockchain / Blockchain Connection
1. Verificar Python / Check Python:
   ```bash
   python --version  # Debe ser 3.8+ / Should be 3.8+
   pip list | grep web3  # Verificar dependencias / Check dependencies
   ```

2. Monitorear OSC / Monitor OSC:
   ```supercollider
   OSCFunc.trace(true);  // Habilitar monitoreo OSC / Enable OSC monitoring
   ```

### Estética Musical / Musical Aesthetic
El sistema está diseñado para crear paisajes sonoros ambient inspirados en:
- **Lawrence English**: Texturas atmosféricas, espacialidad, drones largos
- **Elektron**: Control en tiempo real, secuenciación, modulación compleja
- **Ambient techno**: Ritmos hipnóticos, filtros evolutivos, espacialización

The system is designed to create ambient soundscapes inspired by:
- **Lawrence English**: Atmospheric textures, spatiality, long drones
- **Elektron**: Real-time control, sequencing, complex modulation
- **Ambient techno**: Hypnotic rhythms, evolving filters, spatialization

---

### Dependencies / Dependencias
- SuperCollider 3.13.0+
- Python 3.8+ with web3, python-osc
- Faderfox LC2 MIDI Controller (optional)
- 4-channel audio interface (for quad setup)

### License / Licencia
MIT License - Feel free to experiment and modify / Siéntete libre de experimentar y modificar

### Contact / Contacto
- GitHub: [@alejoduque](https://github.com/alejoduque)
- Repository: [sonETH](https://github.com/alejoduque/sonETH)