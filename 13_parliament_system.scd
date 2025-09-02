// SuperCollider Ethereum Sonification - Parliament Integration System
// Current Date and Time (UTC): 2025-09-02 09:35:00
// Current User's Login: alejoduque
// Purpose: Colombian biodiversity parliament democracy affecting base synthesis

(
s.waitForBoot({
    var totalVotes, consensus, acousticPresence, ednaValidation, fungiChemical, aiConsciousness;
    
    "Initializing Parliament of All Things integration...".postln;
    
    // Parliament agent data - Colombian biodiversity agents
    ~parliament = ();
    ~parliament.agents = (
        acousticSpecies: [
            (name: "Ara macao", votes: 8, presence: 0.6, status: "CR", freq: 220),
            (name: "Atlapetes blancae", votes: 5, presence: 0.8, status: "VU", freq: 330), 
            (name: "Cecropia obtusa", votes: 3, presence: 0.9, status: "LC", freq: 440),
            (name: "Alouatta seniculus", votes: 6, presence: 0.7, status: "VU", freq: 165),
            (name: "Tinamus major", votes: 4, presence: 0.5, status: "LC", freq: 275)
        ],
        
        ednaSites: [
            (name: "Chocó Biogeographic", biodiversity: 0.95, validation: 0.88),
            (name: "Amazon Basin", biodiversity: 0.92, validation: 0.85),
            (name: "Eastern Cordillera", biodiversity: 0.87, validation: 0.90),
            (name: "Caribbean Coast", biodiversity: 0.78, validation: 0.82),
            (name: "Orinoquía Plains", biodiversity: 0.83, validation: 0.87),
            (name: "Pacific Coast", biodiversity: 0.89, validation: 0.84),
            (name: "Magdalena Valley", biodiversity: 0.76, validation: 0.79),
            (name: "Guayana Shield", biodiversity: 0.91, validation: 0.86)
        ],
        
        fungiNetworks: [
            (name: "Northern Mycorrhizal Network", chemical: 0.7, connectivity: 0.8, coverage: 25),
            (name: "Central Spore Network", chemical: 0.6, connectivity: 0.9, coverage: 30),
            (name: "Southern Fungal Web", chemical: 0.8, connectivity: 0.7, coverage: 20),
            (name: "Coastal Decomposer Grid", chemical: 0.5, connectivity: 0.6, coverage: 15)
        ],
        
        aiCore: [
            (name: "Gaia Meta-Governance AI", consciousness: 0.8, optimization: 64, metaGov: 0.75)
        ]
    );
    
    // Parliament control buses (extending existing SøNeth bus architecture)
    ~parliament.controlBuses = (
        consensusLevel: Bus.control(s, 1).set(0.5),      // 0.0 to 1.0
        rotationSpeed: Bus.control(s, 1).set(1.0),       // 0.1 to 2.0
        totalVotes: Bus.control(s, 1).set(26),           // Sum of all agent votes
        acousticPresence: Bus.control(s, 1).set(0.6),    // 0.0 to 1.0
        ednaValidation: Bus.control(s, 1).set(0.88),     // 0.0 to 1.0
        fungiChemical: Bus.control(s, 1).set(0.5),       // 0.0 to 1.0
        aiConsciousness: Bus.control(s, 1).set(0.8),     // 0.0 to 1.0
        aiOptimization: Bus.control(s, 1).set(64)        // 0 to 127
    );
    
    // Parliament state tracking
    ~parliament.state = (
        isActive: false,
        currentConsensus: 0.5,
        lastVoteTime: 0,
        rotationPhase: 0,
        activeAgents: 0
    );
    
    // Democratic voting simulation function
    ~simulateVote = { |proposalType="environmental"|
        var yesVotes, result, voteWeight, voteChance;
        
        totalVotes = 0;
        yesVotes = 0;
        
        "Parliament voting on % proposal...".format(proposalType).postln;
        
        // Each acoustic species votes based on IUCN status weighting
        ~parliament.agents.acousticSpecies.do({ |agent|
            voteWeight = agent.votes;
            voteChance = switch(agent.status,
                "CR", 0.9, // Critically endangered species vote strongly for protection
                "VU", 0.7, // Vulnerable species generally support
                "LC", 0.5  // Least concern species neutral
            );
            
            if(voteChance > 1.0.rand) {
                yesVotes = yesVotes + voteWeight;
                "% votes YES (weight: %)".format(agent.name, voteWeight).postln;
            } {
                "% votes NO (weight: %)".format(agent.name, voteWeight).postln;
            };
            totalVotes = totalVotes + voteWeight;
        });
        
        consensus = yesVotes / totalVotes;
        ~parliament.controlBuses.consensusLevel.set(consensus);
        ~parliament.controlBuses.totalVotes.set(totalVotes); // Store in bus for global access
        ~parliament.state.currentConsensus = consensus;
        
        result = if(consensus > 0.6) { "PASSED" } { "FAILED" };
        
        "Vote Result: % (Consensus: %%)".format(result, (consensus * 100).round(1)).postln;
        "Total Votes: % | Yes Votes: %".format(totalVotes, yesVotes).postln;
        
        consensus;
    };
    
    // Calculate current acoustic species presence
    ~updateAcousticPresence = {
        acousticPresence = ~parliament.agents.acousticSpecies.collect(_.presence).mean;
        ~parliament.controlBuses.acousticPresence.set(acousticPresence);
        acousticPresence;
    };
    
    // Calculate eDNA validation strength
    ~updateEdnaValidation = {
        ednaValidation = ~parliament.agents.ednaSites.collect(_.validation).mean;
        ~parliament.controlBuses.ednaValidation.set(ednaValidation);
        ednaValidation;
    };
    
    // Calculate fungi chemical signaling
    ~updateFungiChemical = {
        fungiChemical = ~parliament.agents.fungiNetworks.collect(_.chemical).mean;
        ~parliament.controlBuses.fungiChemical.set(fungiChemical);
        fungiChemical;
    };
    
    // Update AI consciousness
    ~updateAiConsciousness = {
        aiConsciousness = ~parliament.agents.aiCore[0].consciousness;
        ~parliament.controlBuses.aiConsciousness.set(aiConsciousness);
        aiConsciousness;
    };
    
    // Additive parameter mapping to existing SøNeth base synthesis
    ~mapParliamentToSoneth = {
        var parliamentConsensus, parliamentVotes, parliamentAcoustic, parliamentEdna, parliamentFungi, parliamentAi;
        var additiveDepth, additiveNoise, additiveFilter, additiveTexture, additiveSpatial, additiveHarmonic, additiveTemporal, additivePitch;
        
        // Read current parliament state
        parliamentConsensus = ~parliament.state.currentConsensus;
        parliamentVotes = if(~parliament.controlBuses.totalVotes.notNil) {
            ~parliament.controlBuses.totalVotes.getSynchronous
        } { 26 };
        parliamentAcoustic = acousticPresence ? 0.6;
        parliamentEdna = ednaValidation ? 0.85;
        parliamentFungi = fungiChemical ? 0.65;
        parliamentAi = aiConsciousness ? 0.8;
        
        // Calculate additive modulation values (scaled for audibility)
        additiveDepth = parliamentConsensus.linlin(0, 1, 0, 0.5);        // Add up to 0.5 to drone depth (more audible)
        additiveNoise = parliamentVotes.linlin(0, 26, 0, 0.3);           // Add up to 0.3 to noise level (doubled)
        additiveFilter = parliamentAcoustic.linlin(0, 1, 0, 0.4);       // Add up to 0.4 to filter cutoff (more dramatic)
        additiveTexture = parliamentEdna.linlin(0, 1, 0, 0.4);          // Add up to 0.4 to texture depth (doubled)
        additiveSpatial = parliamentFungi.linlin(0, 1, -0.5, 0.5);      // Add ±0.5 to spatial spread (wider)
        additiveHarmonic = parliamentAi.linlin(0, 1, 1.0, 6.0);         // Add 1.0-6.0 to harmonic richness (more dramatic FM)
        additiveTemporal = ~parliament.controlBuses.rotationSpeed.getSynchronous.linlin(0.1, 2.0, -1.0, 1.0); // Add ±1.0 to time dilation (more dramatic)
        additivePitch = parliamentConsensus.linlin(0, 1, -28, 28);   // Add ±28 semitones pitch shift based on consensus
        
        // Apply Parliament modulation directly to synthesis buses
        if(~buses.notNil) {
            if(~buses.droneDepth.notNil) {
                ~buses.droneDepth.set((~controlValues.droneDepth ? 0.3) + additiveDepth);
            };
            if(~buses.noiseLevel.notNil) {
                ~buses.noiseLevel.set((~controlValues.noiseLevel ? 0.1) + additiveNoise);
            };
            if(~buses.filterCutoff.notNil) {
                ~buses.filterCutoff.set((~controlValues.filterCutoff ? 0.6) + additiveFilter);
            };
            if(~buses.textureDepth.notNil) {
                ~buses.textureDepth.set((~controlValues.textureDepth ? 0.2) + additiveTexture);
            };
            if(~buses.spatialSpread.notNil) {
                ~buses.spatialSpread.set((~controlValues.spatialSpread ? 0.0) + additiveSpatial);
            };
            if(~buses.harmonicRich.notNil) {
                ~buses.harmonicRich.set((~controlValues.harmonicRich ? 1.0) + additiveHarmonic);
            };
            if(~buses.timeDilation.notNil) {
                ~buses.timeDilation.set((~controlValues.timeDilation ? 2.0) + additiveTemporal);
            };
            if(~buses.pitchShift.notNil) {
                ~buses.pitchShift.set((~controlValues.pitchShift ? 0.0) + additivePitch);
            };
        };
        
        "Parliament modulation applied - Consensus: %%".format((parliamentConsensus * 100).round(1)).postln;
    };
    
    // Parliament temporal engine with 120-second rotation cycles
    ~parliament.temporal = ();
    ~parliament.temporal.masterClock = TempoClock(120/60); // 0.5 Hz base frequency
    
    ~startParliamentSystem = {
        "Starting Parliament of All Things system...".postln;
        
        // Initialize agent presence values
        ~updateAcousticPresence.value;
        ~updateEdnaValidation.value;
        ~updateFungiChemical.value;
        ~updateAiConsciousness.value;
        
        // Start parliamentary modulation routine
        ~parliament.modulationRoutine = Routine({
            loop {
                // Update all agent parameters
                ~updateAcousticPresence.value;
                ~updateEdnaValidation.value;
                ~updateFungiChemical.value;
                ~updateAiConsciousness.value;
                
                // Apply additive modulation to SøNeth
                ~mapParliamentToSoneth.value;
                
                // Simulate democratic voting every 30 seconds
                if((~parliament.state.lastVoteTime + 30) < Main.elapsedTime) {
                    ~simulateVote.value;
                    ~parliament.state.lastVoteTime = Main.elapsedTime;
                };
                
                0.1.wait; // Smooth updates every 0.1 seconds
            };
        }).play(AppClock);
        
        ~parliament.state.isActive = true;
        "Parliament system active - Democratic modulation engaged".postln;
    };
    
    ~stopParliamentSystem = {
        "Stopping Parliament system...".postln;
        
        if(~parliament.modulationRoutine.notNil) {
            ~parliament.modulationRoutine.stop;
            ~parliament.modulationRoutine = nil;
        };
        
        ~parliament.state.isActive = false;
        "Parliament system stopped".postln;
    };
    
    // Parliament OSC handlers (same port 57120, different message names)
    OSCdef(\parliamentConsensus, { |msg|
        var newConsensus = msg[1].clip(0.0, 1.0);
        ~parliament.controlBuses.consensusLevel.set(newConsensus);
        ~parliament.state.currentConsensus = newConsensus;
        "Parliament consensus set to: %%".format((newConsensus * 100).round(1)).postln;
    }, '/parliament/consensus');
    
    OSCdef(\parliamentRotation, { |msg|
        var newSpeed = msg[1].clip(0.1, 2.0);
        ~parliament.controlBuses.rotationSpeed.set(newSpeed);
        "Parliament rotation speed: %".format(newSpeed.round(0.01)).postln;
    }, '/parliament/rotation');
    
    OSCdef(\speciesPresence, { |msg|
        var speciesId, newPresence;
        speciesId = msg[1].asInteger.clip(0, 4);
        newPresence = msg[2].clip(0.0, 1.0);
        
        if(speciesId < ~parliament.agents.acousticSpecies.size) {
            ~parliament.agents.acousticSpecies[speciesId].presence = newPresence;
            "Species % presence: %".format(
                ~parliament.agents.acousticSpecies[speciesId].name, 
                newPresence.round(0.01)
            ).postln;
        };
    }, '/agents/species/presence');
    
    OSCdef(\ednaValidation, { |msg|
        var siteId, newValidation;
        siteId = msg[1].asInteger.clip(0, 7);
        newValidation = msg[2].clip(0.0, 1.0);
        
        if(siteId < ~parliament.agents.ednaSites.size) {
            ~parliament.agents.ednaSites[siteId].validation = newValidation;
            "eDNA site % validation: %".format(
                ~parliament.agents.ednaSites[siteId].name, 
                newValidation.round(0.01)
            ).postln;
        };
    }, '/agents/edna/validation');
    
    OSCdef(\fungiChemical, { |msg|
        var nodeId, newChemical;
        nodeId = msg[1].asInteger.clip(0, 3);
        newChemical = msg[2].clip(0.0, 1.0);
        
        if(nodeId < ~parliament.agents.fungiNetworks.size) {
            ~parliament.agents.fungiNetworks[nodeId].chemical = newChemical;
            "Fungi network % chemical level: %".format(
                ~parliament.agents.fungiNetworks[nodeId].name, 
                newChemical.round(0.01)
            ).postln;
        };
    }, '/agents/fungi/chemical');
    
    OSCdef(\aiConsciousness, { |msg|
        var newConsciousness = msg[1].clip(0.0, 1.0);
        ~parliament.agents.aiCore[0].consciousness = newConsciousness;
        ~parliament.controlBuses.aiConsciousness.set(newConsciousness);
        "AI consciousness level: %".format(newConsciousness.round(0.01)).postln;
    }, '/agents/ai/consciousness');
    
    // Emergency response for ecological threats
    ~emergencyResponse = { |threatLevel=0.8|
        var emergencyConsensus = threatLevel.clip(0.0, 1.0);
        
        "ECOLOGICAL EMERGENCY RESPONSE - Threat level: %%".format((threatLevel * 100).round(1)).postln;
        
        // Force high consensus for protection
        ~parliament.controlBuses.consensusLevel.set(emergencyConsensus);
        ~parliament.state.currentConsensus = emergencyConsensus;
        
        // Immediately apply emergency modulation
        ~mapParliamentToSoneth.value;
        
        "Emergency consensus: %%".format((emergencyConsensus * 100).round(1)).postln;
    };
    
    // Test parliament system function
    ~testParliament = {
        "Testing Parliament of All Things integration...".postln;
        
        // Test voting simulation
        ~simulateVote.value("biodiversity protection");
        1.wait;
        
        // Test parameter updates
        ~updateAcousticPresence.value;
        ~updateEdnaValidation.value;
        ~updateFungiChemical.value;
        ~updateAiConsciousness.value;
        1.wait;
        
        // Test additive mapping
        ~mapParliamentToSoneth.value;
        
        "Parliament system test complete".postln;
    };
    
    "Parliament of All Things system initialized".postln;
    "Available functions:".postln;
    "  ~startParliamentSystem.() - Start democratic modulation".postln;
    "  ~stopParliamentSystem.() - Stop parliamentary system".postln;
    "  ~simulateVote.(proposalType) - Simulate democratic vote".postln;
    "  ~emergencyResponse.(threatLevel) - Ecological emergency mode".postln;
    "  ~testParliament.() - Test parliament integration".postln;
    "".postln;
    "Parliamentary agents: 5 species + 8 eDNA sites + 4 fungi networks + 1 AI core".postln;
    "Democratic consensus affects: drone depth, noise level, filter cutoff, texture depth, spatial spread, harmonic richness, time dilation, pitch shift".postln;
});
)