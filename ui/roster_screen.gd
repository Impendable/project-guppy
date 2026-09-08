extends Control

const FISH_CARD := preload("res://ui/fish_card.tscn")

@onready var cycle_label: Label = %CycleLabel
@onready var advance_button: Button = %AdvanceCycleButton
@onready var card_container: VBoxContainer = %FishCardContainer

var registry: TraitRegistry
var lifecycle_config: LifecycleConfig
var roster: Array[FishData] = []

func _ready() -> void:
	registry = load("res://resources/trait_registry.tres")
	lifecycle_config = load("res://resources/lifecycle_config.tres")
	roster = RosterGenerator.generate(registry, Debug.rng)
	
	advance_button.pressed.connect(_on_advance_cycle_button_pressed)
	TimeManager.cycle_advanced.connect(_on_cycle_advanced)
	
	cycle_label.text = "Cycle: %d" % TimeManager.cycle
	_refresh_roster_ui()

func _on_advance_cycle_button_pressed() -> void:
	TimeManager.advance_cycle()
	
func _on_cycle_advanced(cycle: int) -> void:
	var dead := AgingSystem.advance(roster, lifecycle_config)
	for fish in dead:
		roster.erase(fish)
	cycle_label.text = "Cycle: %d" % cycle
	_refresh_roster_ui()
	
func _refresh_roster_ui() -> void:
	for child in card_container.get_children():
		card_container.remove_child(child)
		child.queue_free()
	for fish in roster:
		var card := FISH_CARD.instantiate()
		card_container.add_child(card)
		card.render(fish)
