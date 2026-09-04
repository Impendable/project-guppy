extends Control

@export var fish_card_scene: PackedScene

@onready var fish_card_container: VBoxContainer = %FishCardContainer

func _ready() -> void:
	var registry: TraitRegistry = load("res://resources/trait_registry.tres")
	var rng := Debug.rng
	
	var roster := RosterGenerator.generate(registry, rng)
	
	for fish in roster:
		var card := fish_card_scene.instantiate()
		fish_card_container.add_child(card)
		card.render(fish)
		
	print(rng.seed)
