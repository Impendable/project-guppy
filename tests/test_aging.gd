extends Control

@export var fish_card_scene: PackedScene

const TEST_CYCLES := 30
const CYCLE_TIMER := 3

@onready var fish_card_container: VBoxContainer = %FishCardContainer
@onready var registry: TraitRegistry = load("res://resources/trait_registry.tres")
@onready var rng := Debug.rng
@onready var roster := RosterGenerator.generate(registry, rng)
@onready var lifecycle_config := LifecycleConfig.new()

var time_passed: float = 0.0

func _ready() -> void:
	for fish in roster:
		var card := fish_card_scene.instantiate()
		fish_card_container.add_child(card)
		card.render(fish)
	print(rng.seed)
	
func _process(delta: float):
	time_passed += delta
	if time_passed >= CYCLE_TIMER:
		for i in TEST_CYCLES:
			_run_test_aging()
		time_passed -= CYCLE_TIMER
	
func _refresh_roster_ui() -> void:
	for child in fish_card_container.get_children():
		fish_card_container.remove_child(child)
		child.queue_free()
	for fish in roster:
		var card := fish_card_scene.instantiate()
		fish_card_container.add_child(card)
		card.render(fish)

func _run_test_aging():
		var dead := AgingSystem.advance(roster, lifecycle_config)
		for fish in dead:
			roster.erase(fish)
		_refresh_roster_ui()
