extends Node

func _ready() -> void:
	var traits: TraitRegistry = load("res://resources/trait_registry.tres")
	var genome := FishGenome.new()
	
	for trait_def in traits.traits:
		genome.alleles[trait_def.id] = [trait_def.dominant_allele, trait_def.recessive_allele]
	
	var phenotype := PhenotypeResolver.resolve(genome, traits)
	
	print(genome.alleles)
	print(phenotype)
