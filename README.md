# SøNeth: Parlamento de Todas las Cosas
## Sistema Autónomo de Sonificación Ecológica-Blockchain

### Resumen Conceptual

SøNeth es un experimento de investigación-creación que explora las posibilidades de agencia no-humana y autonomía ecológica a través de la tecnología blockchain y la síntesis sonora. Inspirado en el marco conceptual de [terra0.org](https://terra0.org/), este proyecto constituye una primera iteración sonora hacia la creación de sistemas agénticos autónomos basados en principios DAO (Organización Autónoma Descentralizada).

El sistema implementa un "Parlamento de Todas las Cosas" donde 21 agentes ecológicos colombianos participan en procesos democráticos que modulan directamente la síntesis de audio en tiempo real, transformando datos de transacciones Ethereum en paisajes sonoros gobernados por una democracia multiespecie expandida.

### Marco Teórico: terra0 y Autonomía Ecológica

Siguiendo los principios de terra0, SøNeth interroga las posibilidades de que los sistemas naturales desarrollen capacidades de auto-utilización y auto-gestión a través de la mediación tecnológica. En lugar de instrumentalizar la naturaleza, el proyecto explora la tecnología como una forma de simbiosis que permite la expresión autónoma de entidades no-humanas.

**Principios Fundamentales:**
- **Agencia No-Humana**: Los agentes ecológicos operan con lógicas propias basadas en datos reales de biodiversidad colombiana
- **Personalidad Jurídica Expandida**: Las especies, sitios eDNA y redes fúngicas poseen capacidad de voto y decisión
- **Autonomía Tecnológica**: El sistema opera con mínima intervención humana, siguiendo protocolos democráticos algorítmicos
- **Gobernanza Descentralizada**: Las decisiones emergen del consenso entre múltiples agentes sin autoridad central

### Arquitectura del Parlamento

#### 21 Agentes Ecológicos Autónomos

**5 Especies Acústicas (basadas en datos UICN):**
- *Ara macao* (Guacamaya Bandera) - Críticamente amenazada, 8 votos
- *Atlapetes blancae* - Vulnerable, 5 votos  
- *Cecropia obtusa* - Preocupación menor, 3 votos
- *Alouatta seniculus* (Mono Aullador Rojo) - Vulnerable, 6 votos
- *Tinamus major* (Tinamú Grande) - Preocupación menor, 4 votos

**8 Sitios eDNA (Regiones Biogeográficas):**
- Chocó Biogeográfico, Cuenca Amazónica, Cordillera Oriental
- Costa Caribe, Llanos de la Orinoquía, Costa Pacífica
- Valle del Magdalena, Escudo Guayanés

**4 Redes Fúngicas:**
- Red Micorrízica Norte, Red Central de Esporas
- Telaraña Fúngica Sur, Grid Descomponedor Costero

**1 Núcleo de IA:**
- IA de Meta-Gobernanza Gaia

#### Sistema de Votación Democrática

El parlamento simula procesos democráticos cada 30 segundos donde cada agente vota basándose en:
- **Estado de conservación UICN** (especies amenazadas votan más fuertemente por protección)
- **Niveles de biodiversidad** (sitios eDNA con mayor diversidad tienen más influencia)
- **Conectividad química** (redes fúngicas modulan según comunicación inter-red)
- **Nivel de consciencia** (IA aporta optimización algorítmica)

### Gobernanza Sonora: De Datos a Decisiones

#### Mapeo Paramétrico Aditivo

El consenso parlamentario modula los siguientes parámetros de síntesis base:
- **Profundidad de Drone**: Intensidad consensual (0-0.3 aditivo)
- **Nivel de Ruido**: Densidad de votos (0-0.15 aditivo)
- **Corte de Filtro**: Presencia acústica (0-0.25 aditivo)
- **Profundidad de Textura**: Validación eDNA (0-0.2 aditivo)
- **Dispersión Espacial**: Comunicación fúngica (±0.3 aditivo)
- **Riqueza Armónica**: Consciencia IA (0-2.0 aditivo)
- **Dilatación Temporal**: Velocidad de rotación (±0.5 aditivo)

#### Ciclos Temporales Democráticos

El sistema opera en ciclos de 120 segundos que simulan:
- **Deliberación**: Actualización de parámetros de agentes cada 2 segundos
- **Votación**: Simulación democrática cada 30 segundos
- **Aplicación**: Modulación inmediata de parámetros de síntesis
- **Rotación**: Cambio de fase parlamentaria cada 120 segundos

### Implementación Técnica

#### Arquitectura SuperCollider
```supercollider
// Inicializar sistema parlamentario
~startParliamentSystem.();

// Simular votación democrática
~simulateVote.("protección de biodiversidad");

// Respuesta de emergencia ecológica
~emergencyResponse.(0.8);

// Mapeo aditivo a síntesis base
~mapParliamentToSoneth.();
```

#### Protocolo OSC (Puerto 57120)
- `/parliament/consensus <float>` - Nivel de consenso (0.0-1.0)
- `/agents/species/presence <int> <float>` - Presencia de especies
- `/agents/edna/validation <int> <float>` - Validación genética
- `/agents/fungi/chemical <int> <float>` - Señales químicas
- `/agents/ai/consciousness <float>` - Nivel de consciencia IA

#### Control Buses
Sistema de buses de control unificado entre GUI, OSC y síntesis:

| Parámetro GUI | Bus Creado | Parámetro SynthDef | Función en Campanas |
|---------------|------------|-------------------|-------------------|
| masterVolume | ~buses.masterVolume | masterVolumeBus | Volumen principal |
| pitchShift | ~buses.pitchShift | pitchShiftBus | Transposición ±56 semitonos |
| timeDilation | ~buses.timeDilation | timeDilationBus | Estiramiento temporal |
| spectralShift | ~buses.spectralShift | spectralShiftBus | Frecuencia de filtro espectral |
| spatialSpread | ~buses.spatialSpread | spatialSpreadBus | Posicionamiento espacial |
| textureDepth | ~buses.textureDepth | textureDepthBus | Densidad granular |
| atmosphereMix | ~buses.atmosphereMix | atmosphereMixBus | Nivel de reverberación |
| memoryFeed | ~buses.memoryFeed | memoryFeedBus | Retroalimentación de delay |
| harmonicRich | ~buses.harmonicRich | harmonicRichBus | Complejidad FM |
| resonantBody | ~buses.resonantBody | resonantBodyBus | Resonancia de filtro |
| filterCutoff | ~buses.filterCutoff | filterCutoffBus | Filtro paso-bajo final |
| noiseLevel | ~buses.noiseLevel | noiseLevelBus | Capa de ruido |
| droneDepth | ~buses.droneDepth | droneDepthBus | Intensidad de drone |

#### Controles GUI Parlamentarios (Fila 3 - Color Cian)
- **consensusLevel** → pitchShift: Transposición basada en consenso (±6 semitonos)
- **acousticPresence** → filterCutoff: Brillo de filtro por presencia de especies (0.2-1.0)
- **ednaValidation** → textureDepth: Textura granular por validación genética (0-0.6)
- **fungiChemical** → spatialSpread: Posicionamiento espacial por comunicación fúngica (±1.0)
- **aiConsciousness** → harmonicRich: Complejidad FM por consciencia IA (1-8)

### Interfaz Gráfica Parlamentaria

La GUI integra un panel del "Parlamento de Todas las Cosas" que incluye:
- **Medidor de Consenso**: Visualización en tiempo real del nivel democrático
- **Contador de Votos**: Seguimiento de participación parliamentary (0-26 votos)
- **Estado de Agentes**: Indicadores de actividad por categoría ecológica
- **Controles Parlamentarios**: Botones para iniciar, votar, emergencia y prueba

### Reflexión Crítica: Autonomía vs. Antropomorfismo

Este proyecto navega conscientemente la tensión entre crear autonomía genuina para entidades no-humanas y el riesgo de proyección antropomórfica. Al utilizar datos reales de biodiversidad y estados de conservación, SøNeth busca representar las lógicas propias de cada agente ecológico en lugar de imponer estructuras democráticas humanas.

**Preguntas Abiertas:**
- ¿Puede la tecnología blockchain facilitar formas genuinas de agencia no-humana?
- ¿Cómo suenan las decisiones cuando participan especies, hongos y datos genéticos?
- ¿Qué nuevas formas de gobernanza emergen de la democracia multiespecie?

### Contexto: Democracia Expandida y Sonificación Política

SøNeth propone la sonificación como una forma de gobernanza y expresión política expandida. En lugar de simplemente visualizar datos blockchain, el sistema permite que entidades ecológicas participen activamente en la modulación sonora, creando un espacio donde la democracia trasciende lo humano.

**Inspiraciones Conceptuales:**
- Parlamento de Todas las Cosas (Bruno Latour)
- Democracia de Especies (Donna Haraway) 
- Autonomía Tecnológica (terra0.org)
- Ecología Política Sonora (Hildegard Westerkamp)

### Instalación y Uso

#### Requisitos del Sistema
- SuperCollider 3.13.0+
- Python 3.8+ con bibliotecas de Ethereum
- Audio multi-canal (recomendado 4 canales)
- Conexión a red para datos blockchain

#### Inicio Rápido
```bash
# Navegar al directorio del proyecto
cd "eth_sonification/SøNeth"

# Iniciar en SuperCollider
"start_sonification.scd".loadRelative;

# Activar parlamento ecológico
~startParliamentSystem.();
```

#### Flujo de Trabajo Parlamentario
1. **Cargar Sistema**: Ejecutar `start_sonification.scd`
2. **Iniciar Parlamento**: Usar botón "START PARLIAMENT" en GUI
3. **Observar Democracia**: Monitorear votaciones automáticas cada 30s
4. **Simular Votación**: Botón "SIMULATE VOTE" para intervención manual
5. **Emergencia Ecológica**: Botón "EMERGENCY" para respuesta de protección

### Datos de Biodiversidad Colombiana

El sistema utiliza datos reales de:
- **Especies**: Estado de conservación UICN, frecuencias características
- **Sitios eDNA**: Validación genética por región biogeográfica
- **Redes Fúngicas**: Conectividad química y cobertura territorial
- **IA Ecológica**: Optimización algorítmica de meta-gobernanza

### Filosofía del Proyecto: Hacia una Democracia Sonora Post-Humana

SøNeth imagina un futuro donde las entidades naturales poseen agencia tecnológica directa, participando en sistemas económicos y de gobernanza a través de protocolos blockchain. La sonificación deviene un medio de expresión política para voces tradicionalmente silenciadas en los procesos democráticos humanos.

El proyecto no romantiza la naturaleza ni pretende resolver la crisis ecológica a través de la tecnología. En cambio, explora cómo los protocolos descentralizados podrían ampliar nuestro entendimiento de agencia, representación y participación política en el Antropoceno.

### Metodología de Investigación-Creación

Este trabajo emplea una metodología híbrida que combina:
- **Investigación Tecnológica**: Desarrollo de protocolos DAO para agentes no-humanos
- **Práctica Artística**: Composición sonora algorítmica y síntesis en tiempo real  
- **Activismo Ecológico**: Representación de biodiversidad colombiana amenazada
- **Filosofía Política**: Exploración de democracia expandida y agencia multiespecie

### Futuras Iteraciones

SøNeth representa solo el primer paso hacia sistemas completamente autónomos. Futuras iteraciones podrían incluir:
- **Integración Blockchain Completa**: Smart contracts manejados por agentes ecológicos
- **Sensores Ambientales Reales**: Datos en vivo de ecosistemas colombianos
- **Economía Ecológica**: Tokens y transacciones controladas por el parlamento
- **Red Distribuida**: Múltiples nodos parlamentarios en diferentes bioregiones

### Créditos y Reconocimientos

Desarrollado como parte de investigación doctoral en artes y tecnología, 2024-2025.
Inspirado en el trabajo pionero de terra0.org en autonomía tecnológica y agencia no-humana.
Con profundo respeto hacia la biodiversidad colombiana y las comunidades que la protegen.

### Contacto y Colaboración

Este proyecto busca colaboraciones interdisciplinarias en:
- Ecología política y estudios multiespecie
- Arte sonoro y música algorítmica
- Tecnología blockchain y sistemas autónomos
- Activismo ambiental y conservación

---

*"En el Parlamento de Todas las Cosas, cada voz cuenta: desde el canto del guacamayo hasta el sussurro químico de los hongos, desde los datos genéticos hasta los algoritmos conscientes. La democracia suena diferente cuando incluye a todo el mundo viviente."*

---

**Licencia**: Investigación Abierta - Creative Commons BY-NC-SA 4.0
**Repositorio**: [GitHub - SøNeth Parliament](https://github.com/alejoduque/soneth-parliament)
**Documentación Técnica**: Consultar archivos `.scd` individuales para implementación detallada