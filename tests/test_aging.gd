extends Control

const TEST_CYCLES := 30

func _ready() -> void:
	var registry: TraitRegistry = load("res://resources/trait_registry.tres")
	var config: LifecycleConfig = load("res://resources/lifecycle_config.tres")
	var rng := RandomNumberGenerator.new()
	rng.seed = 13579
	print("RNG seed(AGINGTEST): %d" % rng.seed)
	
	var roster :=RosterGenerator.generate(registry, rng)
	
	for cycle in TEST_CYCLES:
		var dead := AgingSystem.advance(roster, config)
		for fish in dead:
			roster.erase(fish)
		
		var line := "cycle %02d |" % (cycle + 1)
		for fish in roster:
			line += "%s: age %d %s (%s) | " % [
				fish.id, fish.age,
				FishData.LifeStage.find_key(fish.life_stage),
				fish.cached_phenotype_dictionary["growth"],
			]
		for fish in dead:
			line += "DIED %s |" % fish.id
		print(line)
		
		if roster.is_empty():
			print("pond empty at cycle %d" % (cycle + 1)) 
			break


'''
OUTPUT Test 1:
RNG seed(AGINGTEST): 24680
cycle 01 |fish_0: age 8 ADULT (Fast) | fish_1: age 5 ADULT (Fast) | fish_2: age 7 ADULT (Fast) | fish_3: age 7 ADULT (Fast) | fish_4: age 7 ADULT (Slow) | fish_5: age 8 ADULT (Fast) | fish_6: age 5 ADULT (Fast) | 
cycle 02 |fish_0: age 9 OLD (Fast) | fish_1: age 6 ADULT (Fast) | fish_2: age 8 ADULT (Fast) | fish_3: age 8 ADULT (Fast) | fish_4: age 8 ADULT (Slow) | fish_5: age 9 OLD (Fast) | fish_6: age 6 ADULT (Fast) | 
cycle 03 |fish_0: age 10 OLD (Fast) | fish_1: age 7 ADULT (Fast) | fish_2: age 9 OLD (Fast) | fish_3: age 9 OLD (Fast) | fish_4: age 9 OLD (Slow) | fish_5: age 10 OLD (Fast) | fish_6: age 7 ADULT (Fast) | 
cycle 04 |fish_1: age 8 ADULT (Fast) | fish_2: age 10 OLD (Fast) | fish_3: age 10 OLD (Fast) | fish_4: age 10 OLD (Slow) | fish_6: age 8 ADULT (Fast) | DIED fish_0 |DIED fish_5 |
cycle 05 |fish_1: age 9 OLD (Fast) | fish_6: age 9 OLD (Fast) | DIED fish_2 |DIED fish_3 |DIED fish_4 |
cycle 06 |fish_1: age 10 OLD (Fast) | fish_6: age 10 OLD (Fast) | 
cycle 07 |DIED fish_1 |DIED fish_6 |
pond empty at cycle 7
OUTPUT Test 2:
RNG seed(AGINGTEST): 13579
cycle 01 |fish_0: age 7 ADULT (Slow) | fish_1: age 8 ADULT (Fast) | fish_2: age 8 ADULT (Fast) | fish_3: age 5 ADULT (Fast) | fish_4: age 5 ADULT (Fast) | fish_5: age 7 ADULT (Fast) | fish_6: age 5 ADULT (Fast) | 
cycle 02 |fish_0: age 8 ADULT (Slow) | fish_1: age 9 OLD (Fast) | fish_2: age 9 OLD (Fast) | fish_3: age 6 ADULT (Fast) | fish_4: age 6 ADULT (Fast) | fish_5: age 8 ADULT (Fast) | fish_6: age 6 ADULT (Fast) | 
cycle 03 |fish_0: age 9 OLD (Slow) | fish_1: age 10 OLD (Fast) | fish_2: age 10 OLD (Fast) | fish_3: age 7 ADULT (Fast) | fish_4: age 7 ADULT (Fast) | fish_5: age 9 OLD (Fast) | fish_6: age 7 ADULT (Fast) | 
cycle 04 |fish_0: age 10 OLD (Slow) | fish_3: age 8 ADULT (Fast) | fish_4: age 8 ADULT (Fast) | fish_5: age 10 OLD (Fast) | fish_6: age 8 ADULT (Fast) | DIED fish_1 |DIED fish_2 |
cycle 05 |fish_3: age 9 OLD (Fast) | fish_4: age 9 OLD (Fast) | fish_6: age 9 OLD (Fast) | DIED fish_0 |DIED fish_5 |
cycle 06 |fish_3: age 10 OLD (Fast) | fish_4: age 10 OLD (Fast) | fish_6: age 10 OLD (Fast) | 
cycle 07 |DIED fish_3 |DIED fish_4 |DIED fish_6 |
pond empty at cycle 7

OUTPUT Test 3 (Aging Cycle Verification):
RNG seed(AGINGTEST): 13579
cycle 01 |fish_0: age 1 FRY (Fast) | fish_1: age 1 FRY (Slow) | fish_2: age 8 ADULT (Fast) | fish_3: age 5 ADULT (Fast) | fish_4: age 5 ADULT (Fast) | fish_5: age 7 ADULT (Fast) | fish_6: age 5 ADULT (Fast) | 
cycle 02 |fish_0: age 2 JUVENILE (Fast) | fish_1: age 2 JUVENILE (Slow) | fish_2: age 9 OLD (Fast) | fish_3: age 6 ADULT (Fast) | fish_4: age 6 ADULT (Fast) | fish_5: age 8 ADULT (Fast) | fish_6: age 6 ADULT (Fast) | 
cycle 03 |fish_0: age 3 ADULT (Fast) | fish_1: age 3 JUVENILE (Slow) | fish_2: age 10 OLD (Fast) | fish_3: age 7 ADULT (Fast) | fish_4: age 7 ADULT (Fast) | fish_5: age 9 OLD (Fast) | fish_6: age 7 ADULT (Fast) | 
cycle 04 |fish_0: age 4 ADULT (Fast) | fish_1: age 4 ADULT (Slow) | fish_3: age 8 ADULT (Fast) | fish_4: age 8 ADULT (Fast) | fish_5: age 10 OLD (Fast) | fish_6: age 8 ADULT (Fast) | DIED fish_2 |
cycle 05 |fish_0: age 5 ADULT (Fast) | fish_1: age 5 ADULT (Slow) | fish_3: age 9 OLD (Fast) | fish_4: age 9 OLD (Fast) | fish_6: age 9 OLD (Fast) | DIED fish_5 |
cycle 06 |fish_0: age 6 ADULT (Fast) | fish_1: age 6 ADULT (Slow) | fish_3: age 10 OLD (Fast) | fish_4: age 10 OLD (Fast) | fish_6: age 10 OLD (Fast) | 
cycle 07 |fish_0: age 7 ADULT (Fast) | fish_1: age 7 ADULT (Slow) | DIED fish_3 |DIED fish_4 |DIED fish_6 |
cycle 08 |fish_0: age 8 ADULT (Fast) | fish_1: age 8 ADULT (Slow) | 
cycle 09 |fish_0: age 9 OLD (Fast) | fish_1: age 9 OLD (Slow) | 
cycle 10 |fish_0: age 10 OLD (Fast) | fish_1: age 10 OLD (Slow) | 
cycle 11 |DIED fish_0 |DIED fish_1 |
pond empty at cycle 11
'''
