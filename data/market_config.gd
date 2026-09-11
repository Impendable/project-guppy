class_name MarketConfig
extends Resource

@export var base_value: int = 10
@export var forecast_horizon: int = 4
@export var gold: Array[float] = []
@export var long_fins: Array[float] = []
@export var glow: Array[float] = []

func cycle_count() -> int:
	return gold.size()


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	
	if base_value <= 0:
		errors.append("Base value must be positive.")
	if forecast_horizon < 1:
		errors.append("Forecast horzon must be at least one cycle.")
	if gold.is_empty():
		errors.append("The demand schedule is empty.")
	if long_fins.size() != gold.size() or glow.size() != gold.size():
		errors.append("Every demand array must cover the same cycles.")
		
	for series in [gold, long_fins, glow]:
		for modifier: float in series:
			if not is_finite(modifier) or modifier <= 0.0:
				errors.append("Demand modifiers must be finite and positive.")
				
	return errors
