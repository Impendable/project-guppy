extends Node

@export var use_fixed_seed: bool = true
@export var fixed_seed: int = 12345

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	if use_fixed_seed:
		rng.seed = fixed_seed
	else:
		rng.randomize()
		
	print("RNG seed: ", rng.seed)
	
