class_name FishCard
extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var age_label: Label = %AgeLabel
@onready var sex_label: Label = %SexLabel
@onready var stage_label: Label = %StageLabel
@onready var trait_container: HBoxContainer = %FishTraitContainer

func render(fish: FishData):
	var traits_text: String = ""
	var trait_label := Label.new()
	
	for trait_id in fish.cached_phenotype_dictionary:
		traits_text += "%s: %s |" % [
			trait_id.capitalize(),
			fish.cached_phenotype_dictionary[trait_id],
			]
	name_label.text = "Name: %s |" % fish.display_name
	age_label.text = "Age: %d |" % fish.age
	sex_label.text = "Sex: %s |" % FishData.Sex.find_key(fish.sex)
	stage_label.text = "Stage: %s" % FishData.LifeStage.find_key(fish.life_stage)
	
	trait_label.text = traits_text
	trait_container.add_child(trait_label)
