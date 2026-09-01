extends Node

const RUNS := 1000

func _ready() -> void:
	var color: TraitDefinition = load("res://resources/traits/color.tres")
	var rng := RandomNumberGenerator.new()
	var test_seed := 12345
	rng.seed = test_seed
	
	var parent_a := FishGenome.new()
	var parent_b := FishGenome.new()
	
	parent_a.alleles["color"] = [color.dominant_allele, color.recessive_allele]
	parent_b.alleles["color"] = [color.dominant_allele, color.recessive_allele]
	
	var gold := 0
	for i in RUNS:
		var child := BreedingSystem.breed(parent_a, parent_b, rng)
		if color.phenotype_for(child.alleles["color"]) == color.dominant_phenotype:
			gold += 1
	
	print("Gold: %d, Ratio: %.4f" % [gold, float(gold)/RUNS])
		
