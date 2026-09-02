class_name RosterGenerator
extends RefCounted

const GLOW := ['B','b']
const GLOWING_CARRIERS := 2

static func generate(registry: TraitRegistry, rng: RandomNumberGenerator) -> Array[FishData]:
	var starting_amount := rng.randi_range(6, 10)
	var allele_picker := rng.randi_range(0, 1)
	var gender_decider = FishData.Sex.values().pick_random()
	var overwrite := rng.randi_range(0, 5)
	var new_fish: FishData
	var new_genome: FishGenome
	var counter := 0
	var roster: Array = []
	for fish in starting_amount:
		new_fish.id = "fish_%d" % counter
		new_fish.display_name = new_fish.id
		new_fish.sex = gender_decider
		new_fish.age = 1
		new_fish.life_stage = FishData.LifeStage.ADULT
		for allele in registry.traits:
			new_genome.alleles[allele] = [allele[allele.picker], allele[allele.picker]]
		new_fish.genome = new_genome
		new_fish.cached_phenotype_dictionary = PhenotypeResolver.resolve(new_genome, registry)
		new_fish.lineage = []
		new_fish.health = 100
		
		roster.append(new_fish)
		counter += 1
	
	# Two glow carriers guaranteed
	roster[0].genome.alleles["glow"] = ["B", "b"]
	roster[1].genome.alleles["glow"] = ["B", "b"]
	
	# Guarantee breeding
	roster[0].sex = FishData.Sex.FEMALE
	roster[1].sex = FishData.Sex.MALE
	
	return roster
	
