class_name TraitDefinition
extends Resource

@export var id: String					# "color"
@export var dominant_allele: String 	# "G"
@export var recessive_allele: String	# "g"
@export var dominant_phenotype: String	# "Gold"
@export var recessive_phenotype: String	# "Silver

func phenotype_for(pair: Array) -> String:
	return dominant_phenotype if dominant_allele in pair else recessive_phenotype
