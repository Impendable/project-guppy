class_name BreedingSystem
extends RefCounted  #NOT NODE - sim/rule made visible

static func breed(parent_a: FishGenome, parent_b: FishGenome, rng: RandomNumberGenerator) -> FishGenome:
	var offspring := FishGenome.new()
	for trait_id in parent_a.alleles:
		var pair_a: Array = parent_a.alleles[trait_id]
		var pair_b: Array = parent_b.alleles[trait_id]
		#1. pick one allele from pair_a using rng (rng.randi_range(0,1) is an index)
		var random_a: int = rng.randi_range(0, 1)

		#2. pick one from pair b
		var random_b: int = rng.randi_range(0, 1)		
		#3. store both in new array on offspring.alleles[trait_id]
		offspring.alleles[trait_id] = [pair_a[random_a], pair_b[random_b]]
		
	return offspring
