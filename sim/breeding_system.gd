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

static func make_offspring(mom: FishData, dad: FishData, offspring_id: String, registry: TraitRegistry, rng: RandomNumberGenerator) -> FishData:
	assert(
		not offspring_id.is_empty(),
		"Offspring needs a session-assigned ID."
	)
	
	var offspring := FishData.new()
	offspring.id = offspring_id
	offspring.display_name = offspring_id
	
	offspring.genome = breed(mom.genome, dad.genome, rng)
	offspring.cached_phenotype_dictionary = PhenotypeResolver.resolve(
		offspring.genome,
		registry
	)
	
	offspring.age = 0
	offspring.life_stage = FishData.LifeStage.FRY
	
	offspring.sex = (
		FishData.Sex.FEMALE
		if rng.randi_range(0,1) == 0
		else FishData.Sex.MALE
	)
	
	offspring.health = 100
	offspring.lineage = [mom.id, dad.id]
	
	return offspring
