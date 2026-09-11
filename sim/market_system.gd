class_name MarketSystem
extends RefCounted

static func price_for(fish: FishData, cycle: int, config: MarketConfig) -> int:
	assert(fish != null, "Pricing requires a fish.")
	var demand := modifiers_for(cycle, config)
	var price := float(config.base_value)
	
	for phenotype: String in fish.cached_phenotype_dictionary.values():
		price *= float(demand.get(phenotype, 1.0))
		
	return roundi(price)
	

static func modifiers_for(cycle: int, config: MarketConfig) -> Dictionary[String, float]:
	assert(config != null, "Pricing requires market confing.")
	assert(config.validation_errors().is_empty(), "Invalid market config.")
	assert(cycle >= 1 and cycle <= config.cycle_count(), "Market cycle is outside the authored schedule.")
	
	var index := cycle -1
	return {
		"Gold": config.gold[index],
		"Long": config.long_fins[index],
		"Glow": config.glow[index],
	}


static func upcoming_rises(cycle: int, config: MarketConfig) -> Array[Dictionary]:
	var rises: Array[Dictionary] = []
	var previous := modifiers_for(cycle, config)
	var last_visible_cycle := mini(cycle + config.forecast_horizon, config.cycle_count())
	
	for future_cycle in range(cycle + 1, last_visible_cycle + 1):
		var future := modifiers_for(future_cycle, config)
		
		for phenotype: String in future:
			if future[phenotype] > previous[phenotype]:
				rises.append({
					"phenotype": phenotype,
					"cycle": future_cycle,
					"cycles_until": future_cycle - cycle,
				})
				
		previous = future
	
	return rises
