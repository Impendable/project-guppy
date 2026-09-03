extends Node

func _ready() -> void:
	var trait_list: TraitRegistry = load("res://resources/trait_registry.tres")
	var rng := RandomNumberGenerator.new()
	var test_seed := 24680
	rng.seed = test_seed
	
	var roster := RosterGenerator.generate(trait_list, rng)
	
	for fish in roster:
		print(fish.genome.alleles)
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
