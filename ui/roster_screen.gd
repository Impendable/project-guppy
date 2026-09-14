extends Control

const FISH_CARD := preload("res://ui/fish_card.tscn")
const MAX_SELECTED_PARENTS := 2

@onready var cycle_label: Label = %CycleLabel
@onready var advance_button: Button = %AdvanceCycleButton
@onready var breed_button: Button = %BreedButton
@onready var breed_result_label: Label = %BreedResultlabel
@onready var card_container: VBoxContainer = %FishCardContainer

var run: RunState

var selected_parent_ids: Array[String] = []
var cards_by_id: Dictionary[String, FishCard] = {}


func _ready() -> void:
	var registry := load("res://resources/trait_registry.tres") as TraitRegistry
	var lifecycle := load("res://resources/lifecycle_config.tres") as LifecycleConfig
	var market := load("res://resources/checkpoint_market.tres") as MarketConfig
	run = RunState.new(registry, lifecycle, market)
	
	advance_button.pressed.connect(_on_advance_cycle_button_pressed)
	breed_button.pressed.connect(_on_breed_button_pressed)
	run.changed.connect(_refresh_roster_ui)
	_start_new_run()


func _on_advance_cycle_button_pressed() -> void:
	run.advance_cycle()


func _refresh_roster_ui() -> void:
	cycle_label.text = "Cycle: %d/%d | Fish: %d/%d" % [run.cycle, run.last_cycle(), run.roster.size(), RunState.ROSTER_CAPACITY]
	advance_button.disabled = not run.can_advance_cycle()
	var live_ids: Array[String] = []
	
	for fish in run.roster:
		assert(not fish.id.is_empty(), "A fish has no ID.")
		assert(
			not live_ids.has(fish.id),
			"Duplilcate fish ID: %s" % fish.id
		)
		live_ids.append(fish.id)
		
	#Clear selections that no longer refer to eligible fish.
	for fish_id in selected_parent_ids.duplicate():
		var selected_fish := _find_fish(fish_id)
		
		if selected_fish == null:
			selected_parent_ids.erase(fish_id)
		elif selected_fish.life_stage != FishData.LifeStage.ADULT:
			selected_parent_ids.erase(fish_id)
			
	#Remove only cards whose fish have left roster
	for fish_id in cards_by_id.keys():
		if not live_ids.has(fish_id):
			var obsolete_card: FishCard = cards_by_id[fish_id]
			cards_by_id.erase(fish_id)
			card_container.remove_child(obsolete_card)
			obsolete_card.queue_free()
			
	#Create missing cards and update all surviving cards
	for index in range(run.roster.size()):
		var fish := run.roster[index]
		
		if not cards_by_id.has(fish.id):
			var new_card := FISH_CARD.instantiate() as FishCard
			new_card.name = "Card_%s" % fish.id
			card_container.add_child(new_card)
			new_card.card_clicked.connect(
				_on_parent_selection_requested
			)
			cards_by_id[fish.id] = new_card
			
		var card: FishCard = cards_by_id[fish.id]
		card.render(
			fish,
			selected_parent_ids.has(fish.id),
			_can_select_parent(fish),
		)
		
		if card.get_index() != index:
			card_container.move_child(card, index)

	_refresh_breed_button()


func _on_parent_selection_requested(fish_id: String) -> void:
	var fish := _find_fish(fish_id)
	
	if fish == null:
		return
	
	if selected_parent_ids.has(fish_id):
		selected_parent_ids.erase(fish_id)
	elif _can_select_parent(fish):
		selected_parent_ids.append(fish_id)
		

	_refresh_roster_ui()


func _can_select_parent(fish: FishData) -> bool:
	if fish.life_stage != FishData.LifeStage.ADULT:
		return false

	#Selected parents stay clickable so they can be deselected
	if selected_parent_ids.has(fish.id):
		return true

	if selected_parent_ids.size() >= MAX_SELECTED_PARENTS:
		return false

	for selected_id in selected_parent_ids:
		var other_parent := _find_fish(selected_id)

		if other_parent != null and other_parent.sex == fish.sex:
			return false

	return true


func _find_fish(fish_id: String) -> FishData:
	return run.find_fish(fish_id)


func _refresh_breed_button() -> void:
	var reason := _breeding_block_reason()
	breed_button.disabled = not reason.is_empty()
	breed_button.tooltip_text = (reason if not reason.is_empty() else "Create one fry in a free roster slot.")


func _on_breed_button_pressed() -> void:
	var reason := _breeding_block_reason()
	if not reason.is_empty():
		breed_result_label.text = reason
		return
	
	var offspring := run.breed_pair(selected_parent_ids[0], selected_parent_ids[1])
	if offspring == null:
		return
	
	breed_result_label.text = "Last birth: %s | Glow: %s" % [
		offspring.display_name, 
		offspring.cached_phenotype_dictionary["glow"]
	]


func _start_new_run() -> void:
	selected_parent_ids.clear()
	breed_result_label.text = "No offspring yet."
	run.start_new_run(Debug.rng.seed)


func _breeding_block_reason() -> String:
	if selected_parent_ids.size() != MAX_SELECTED_PARENTS:
		return "Select one adult female and one adult male."
	return run.breeding_block_reason(selected_parent_ids[0], selected_parent_ids[1])
