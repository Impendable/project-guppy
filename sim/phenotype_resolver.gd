class_name PhenotypeResolver
extends RefCounted

static func resolve(genome: FishGenome, registry: TraitRegistry) -> Dictionary:
	var phenotypes := {}											# File the answers, starts empty
	for trait_def in registry.traits:								# For each TraitDefinition in registry
		var pair: Array = genome.alleles[trait_def.id]				# Look up genome's pair for that traits id
		phenotypes[trait_def.id] = trait_def.phenotype_for(pair)	# Ask definition, file under id
	
	return phenotypes												# Return collection
