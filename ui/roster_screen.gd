extends Control

const FISH_CARD := preload("res://ui/fish_card.tscn")
const MAX_SELECTED_PARENTS := 2

@onready var cycle_label: Label = %CycleLabel
@onready var advance_button: Button = %AdvanceCycleButton
@onready var breed_button: Button = %BreedButton
@onready var breed_result_label: Label = %BreedResultlabel
@onready var card_container: VBoxContainer = %FishCardContainer

var registry: TraitRegistry
var lifecycle_config: LifecycleConfig

var roster: Array[FishData] = []
var selected_parent_ids: Array[String] = []
var cards_by_id: Dictionary[String, FishCard] = {}
var next_fish_id: int = 0


func _ready() -> void:
	registry = load("res://resources/trait_registry.tres")
	lifecycle_config = load("res://resources/lifecycle_config.tres")
	roster = RosterGenerator.generate(registry, Debug.rng)
	next_fish_id = roster.size()
	
	advance_button.pressed.connect(_on_advance_cycle_button_pressed)
	TimeManager.cycle_advanced.connect(_on_cycle_advanced)
	breed_button.pressed.connect(_on_breed_button_pressed)
	
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
	var live_ids: Array[String] = []
	
	for fish in roster:
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
	for index in range(roster.size()):
		var fish := roster[index]
		
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
	for fish in roster:
		if fish.id == fish_id:
			return fish
			
	return null


func _allocate_fish_id() -> String:
	var allocated_id := "fish_%d" % next_fish_id
	next_fish_id += 1
	return allocated_id


func _get_breeding_parents() -> Array[FishData]:
	if selected_parent_ids.size() != MAX_SELECTED_PARENTS:
		return []
	if selected_parent_ids[0] == selected_parent_ids[1]:
		return []
		
	var first := _find_fish(selected_parent_ids[0])
	var second := _find_fish(selected_parent_ids[1])
	
	if first == null or second == null:
		return []
	if(
		first.life_stage != FishData.LifeStage.ADULT
		or second.life_stage != FishData.LifeStage.ADULT
	):
		return []
	#Always return mother first and father second
	if(
		first.sex == FishData.Sex.FEMALE
		and second.sex == FishData.Sex.MALE
	):
		return [first, second]
	if(
		first.sex == FishData.Sex.MALE
		and second.sex== FishData.Sex.FEMALE
	):
		return[second, first]
	return []


func _refresh_breed_button() -> void:
	var parents := _get_breeding_parents()
	
	breed_button.disabled = parents.is_empty()
	
	breed_button.tooltip_text = (
		"Select one adult female and one adult male."
		if parents.is_empty()
		else "Create one fry without advancing the cycle."
	)


func _on_breed_button_pressed() -> void:
	var parents := _get_breeding_parents()
	
	#Recheck the actual data before allocating an ID or breeding
	if parents.is_empty():
		_refresh_roster_ui()
		return
	var offspring := BreedingSystem.make_offspring(
		parents[0],
		parents[1],
		_allocate_fish_id(),
		registry,
		Debug.rng
	)
	
	roster.append(offspring)
	
	breed_result_label.text = "Last birth: %s | Glow: %s" % [
		offspring.display_name,
		offspring.cached_phenotype_dictionary["glow"],
	]
	
	_refresh_roster_ui()
