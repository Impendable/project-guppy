class_name FishCard
extends PanelContainer

@export var selection_color: Color = Color("39dbd7ff")

signal card_clicked(fish_id: String)

@onready var name_label: Label = %NameLabel
@onready var age_label: Label = %AgeLabel
@onready var sex_label: Label = %SexLabel
@onready var stage_label: Label = %StageLabel
@onready var trait_label: Label = %TraitLabel
@onready var trait_container: HBoxContainer = %FishTraitContainer

var _fish_id: String = ""
var _can_select: bool = false
var _panel_style: StyleBoxFlat

func _ready() -> void:
	self_modulate = Color.WHITE
	
	_panel_style = StyleBoxFlat.new()
	_panel_style.set_border_width_all(3)
	_panel_style.set_corner_radius_all(6)
	
	add_theme_stylebox_override("panel", _panel_style)
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_force_pass_scroll_events = true
	
	#Decorative Children Must Not Intercept Clicks On Card
	for node in find_children("*", "Control", true, false):
		var child_control := node as Control
		child_control.mouse_filter = Control.MOUSE_FILTER_IGNORE


func render(fish: FishData, is_selected: bool = false, can_select: bool = false) -> void:
	_fish_id = fish.id
	_can_select = can_select
	
	name_label.text = "Name: %s |" % fish.display_name
	age_label.text = "Age: %d |" % fish.age
	sex_label.text = "Sex: %s |" % FishData.Sex.find_key(fish.sex)
	stage_label.text = "Stage: %s" % FishData.LifeStage.find_key(fish.life_stage)
	
	var trait_parts := PackedStringArray()
	
	for trait_id in fish.cached_phenotype_dictionary:
		trait_parts.append("%s: %s" % [
			str(trait_id).capitalize(),
			fish.cached_phenotype_dictionary[trait_id],
		])
		
	trait_label.text = " | ".join(trait_parts)
	
	_panel_style.bg_color = (
		Color("#3c4657") if is_selected else Color("#252932")
	)
	_panel_style.border_color = (
		selection_color if is_selected else Color("#555b66")
	)
	
func _gui_input(event: InputEvent) -> void:
	if not _can_select or _fish_id.is_empty():
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			accept_event()
			card_clicked.emit(_fish_id)
