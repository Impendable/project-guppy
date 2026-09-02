extends Node

var test_genome: Dictionary = {
		"color": ['G', 'g'],
		"fin length": ['L', 'l'],
		"growth": ['F', 'f'],
		"glow": ['B', 'b']
		}

func _ready() -> void:
	var traits: TraitRegistry = load("res://resources/trait_registry.tres")
	var genome := FishGenome.new()
	
	genome.alleles = test_genome
	var phenotype := PhenotypeResolver.resolve(genome, traits)
	
	print(genome.alleles)
	print(phenotype)
