class_name AgingSystem
extends RefCounted

const FAST_GROWTH := "Fast"

static func advance(roster: Array[FishData], config: LifecycleConfig) -> Array[FishData]:
	var dead: Array[FishData] = []
	#Age every living fish, rederive stages
	for fish in roster:
		fish.age += 1
		if _is_past_lifespan(fish.age, config):
			dead.append(fish)
			continue
		fish.life_stage = _stage_for(fish.age, fish.cached_phenotype_dictionary["growth"], config)
	#Return the fish that died this cycle
	return dead

static func _boundaries(growth_phenotype: String, config: LifecycleConfig) -> Dictionary:
	var fry_end := config.fry_cycles
	var mature_at := fry_end + config.juvenile_cycles
	if growth_phenotype == FAST_GROWTH:
		mature_at -= config.fast_growth_discount
	var old_at := config.fry_cycles+ config.juvenile_cycles + config.adult_cycles
	var death_after := old_at + config.old_cycles
	
	return {
		"fry_end": fry_end,
		"mature_at": mature_at,
		"old_at": old_at,
		"death_after": death_after,
	}


static func _is_past_lifespan(age: int, config: LifecycleConfig) -> bool:
	return age > _boundaries("", config)["death_after"]



static func _stage_for(age: int, growth_phenotype: String, config: LifecycleConfig) -> FishData.LifeStage:
	var b := _boundaries(growth_phenotype, config)
	#build cumulative boundaries from config durations:
	if age <= b["fry_end"]: return FishData.LifeStage.FRY
	if age <= b["mature_at"]: return FishData.LifeStage.JUVENILE
	if age <= b["old_at"]: return FishData.LifeStage.ADULT
	return FishData.LifeStage.OLD
