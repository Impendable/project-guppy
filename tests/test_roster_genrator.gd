extends Node

func _ready() -> void:
	var trait_list: TraitRegistry = load("res://resources/trait_registry.tres")
	var rng := RandomNumberGenerator.new()
	var test_seed := 36900
	rng.seed = test_seed
	
	var roster := RosterGenerator.generate(trait_list, rng)
	
	for fish in roster:
		var  traits_text := ""
		for trait_id in fish.cached_phenotype_dictionary:
			traits_text += "%s: %s%s -> %s |" % [
				trait_id,
				fish.genome.alleles[trait_id][0], fish.genome.alleles[trait_id][1],
				fish.cached_phenotype_dictionary[trait_id],
				]
		print("ID: %s %s %s | %s" % [
			fish.id, FishData.Sex.find_key(fish.sex), FishData.LifeStage.find_key(fish.life_stage),traits_text
		])
	print("RNG seed(ROSTERGENTEST): ", rng.seed)

#First Output:
'''
{ "color": ["g", "G"], "fin length": ["L", "L"], "glow": ["B", "b"], "growth": ["F", "f"] }
{ "color": ["g", "g"], "fin length": ["l", "L"], "glow": ["B", "b"], "growth": ["F", "f"] }
{ "color": ["g", "g"], "fin length": ["L", "l"], "glow": ["B", "B"], "growth": ["F", "f"] }
{ "color": ["G", "G"], "fin length": ["L", "L"], "glow": ["B", "B"], "growth": ["F", "F"] }
{ "color": ["G", "G"], "fin length": ["L", "L"], "glow": ["B", "B"], "growth": ["F", "F"] }
{ "color": ["g", "g"], "fin length": ["l", "L"], "glow": ["B", "B"], "growth": ["F", "f"] }
{ "color": ["G", "G"], "fin length": ["L", "l"], "glow": ["B", "B"], "growth": ["F", "f"] }
RNG seed(ROSTERGENTEST): 13579
'''
#Second Output:
'''
{ "color": ["G", "G"], "fin length": ["l", "l"], "glow": ["B", "b"], "growth": ["F", "f"] }
{ "color": ["G", "G"], "fin length": ["L", "L"], "glow": ["B", "b"], "growth": ["f", "f"] }
{ "color": ["G", "G"], "fin length": ["L", "l"], "glow": ["B", "B"], "growth": ["f", "F"] }
{ "color": ["G", "g"], "fin length": ["L", "l"], "glow": ["B", "B"], "growth": ["f", "F"] }
{ "color": ["G", "G"], "fin length": ["l", "L"], "glow": ["B", "B"], "growth": ["F", "F"] }
{ "color": ["G", "G"], "fin length": ["l", "l"], "glow": ["B", "B"], "growth": ["f", "F"] }
{ "color": ["G", "g"], "fin length": ["l", "L"], "glow": ["B", "B"], "growth": ["f", "F"] }
RNG seed(ROSTERGENTEST): 24680
'''
#Output with same seed 1:
'''
ID: fish_0 FEMALE ADULT | color: gg -> Silver | fin length: LL -> Long | glow: Bb -> Non-glow | growth: ff -> Slow
ID: fish_1 MALE ADULT | color: GG -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: fF -> Fast
ID: fish_2 FEMALE ADULT | color: gg -> Silver | fin length: Ll -> Long | glow: BB -> Non-glow | growth: ff -> Slow
ID: fish_3 MALE ADULT | color: GG -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: Ff -> Fast
ID: fish_4 FEMALE ADULT | color: gG -> Gold | fin length: lL -> Long | glow: BB -> Non-glow | growth: fF -> Fast
ID: fish_5 MALE ADULT | color: Gg -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: fF -> Fast
ID: fish_6 FEMALE ADULT | color: gG -> Gold | fin length: ll -> Short | glow: BB -> Non-glow | growth: ff -> Slow
ID: fish_7 FEMALE ADULT | color: GG -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: FF -> Fast
ID: fish_8 FEMALE ADULT | color: gG -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: fF -> Fast
RNG seed(ROSTERGENTEST): 36900
'''
#Output with same seed 2:
'''
ID: fish_0 FEMALE ADULT | color: gg -> Silver | fin length: LL -> Long | glow: Bb -> Non-glow | growth: ff -> Slow
ID: fish_1 MALE ADULT | color: GG -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: fF -> Fast
ID: fish_2 FEMALE ADULT | color: gg -> Silver | fin length: Ll -> Long | glow: BB -> Non-glow | growth: ff -> Slow
ID: fish_3 MALE ADULT | color: GG -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: Ff -> Fast
ID: fish_4 FEMALE ADULT | color: gG -> Gold | fin length: lL -> Long | glow: BB -> Non-glow | growth: fF -> Fast
ID: fish_5 MALE ADULT | color: Gg -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: fF -> Fast
ID: fish_6 FEMALE ADULT | color: gG -> Gold | fin length: ll -> Short | glow: BB -> Non-glow | growth: ff -> Slow
ID: fish_7 FEMALE ADULT | color: GG -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: FF -> Fast
ID: fish_8 FEMALE ADULT | color: gG -> Gold | fin length: Ll -> Long | glow: BB -> Non-glow | growth: fF -> Fast
RNG seed(ROSTERGENTEST): 36900
'''
