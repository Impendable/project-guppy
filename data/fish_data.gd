class_name FishData
extends Resource

enum LifeStage { FRY, JUVENILE, ADULT, OLD}
enum Sex { MALE, FEMALE }

@export var id: String
@export var display_name: String
@export var sex: Sex
@export var age: int
@export var life_stage: LifeStage
@export var genome: FishGenome
@export var cached_phenotype_dictionary: Dictionary
@export var lineage: Array[String]
@export var health: int
