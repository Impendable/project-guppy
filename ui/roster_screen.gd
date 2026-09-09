extends Control

const FISH_CARD := preload("res://ui/fish_card.tscn")
const MAX_SELECTED_PARENTS := 2

@onready var cycle_label: Label = %CycleLabel
@onready var advance_button: Button = %AdvanceCycleButton
@onready var card_container: VBoxContainer = %FishCardContainer

var registry: TraitRegistry
var lifecycle_config: LifecycleConfig

var roster: Array[FishData] = []
var selected_parent_ids: Array[String] = []
var cards_by_id: Dictionary[String, FishCard] = {}


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
	
	
