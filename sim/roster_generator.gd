class_name RosterGenerator
extends RefCounted

const GLOWING_CARRIER_COUNT := 2
const MIN_FISH := 6
const MAX_FISH := 10



static func generate(registry: TraitRegistry, rng: RandomNumberGenerator) -> Array[FishData]:
	assert(GLOWING_CARRIER_COUNT < MIN_FISH, "More Carriers than fish: %d/%d" % [GLOWING_CARRIER_COUNT, MIN_FISH])
	var roster: Array[FishData] = []
	var starting_amount := rng.randi_range(MIN_FISH, MAX_FISH)
	
	for i in starting_amount:
		var new_fish := FishData.new()
		var new_genome := FishGenome.new()
		
		new_fish.id = "fish_%d" % i
		new_fish.display_name = new_fish.id
		new_fish.sex = FishData.Sex.values()[rng.randi_range(0, 1)]
		new_fish.age = 1
		new_fish.life_stage = FishData.LifeStage.ADULT
		new_fish.lineage = []
		new_fish.health = 100
		#Build alleles on fish
		for trait_def in registry.traits:
			var options := [trait_def.dominant_allele, trait_def.recessive_allele]
			var pick_a: String = options[rng.randi_range(0, 1)]
			var pick_b: String = options[rng.randi_range(0, 1)]
			new_genome.alleles[trait_def.id] = [pick_a, pick_b]
			
		new_fish.genome = new_genome
		roster.append(new_fish)
		
	#Guarantee Glow Pair Genomes
	for i in GLOWING_CARRIER_COUNT:
		var glow: TraitDefinition = load("res://resources/traits/glow.tres")
		roster[i].genome.alleles["glow"] = [glow.dominant_allele, glow.recessive_allele]
		
	# Guarantee breeding pair
	roster[0].sex = FishData.Sex.FEMALE
	roster[1].sex = FishData.Sex.MALE	
	
	# Resolve Phenotypes Once.
	for fish in roster:
		fish.cached_phenotype_dictionary = PhenotypeResolver.resolve(fish.genome, registry)

	return roster
	
