extends SceneTree

const EXPECTED_COMBO := [30, 30, 30, 30, 40, 40, 40, 10, 10, 10]
const EXPECTED_GLOW := [10, 10, 10, 10, 10, 10, 10, 60, 60, 60]

var _failures: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var config := load("res://resources/checkpoint_market.tres") as MarketConfig
	_check(config != null, "Market resource loads.")
	if config == null:
		_finish()
		return

	var errors := config.validation_errors()
	_check(errors.is_empty(), "Valid config: %s" % str(errors))
	_check(config.cycle_count() == 10, "Schedule covers ten cycles.")
	if _failures > 0:
		_finish()
		return

	var combo := _fish("Gold", "Long", "Non-glow")
	var glowing := _fish("Silver", "Short", "Glow")
	var neutral := _fish("Silver", "Short", "Non-glow")
	var original_phenotypes := combo.cached_phenotype_dictionary.duplicate(true)
	var original_gold := config.gold.duplicate()
	var original_fins := config.long_fins.duplicate()
	var original_glow := config.glow.duplicate()

	print("Cycle | Gold + Long | Glow only")
	for cycle in range(1, config.cycle_count() + 1):
		var combo_price := MarketSystem.price_for(combo, cycle, config)
		var glow_price := MarketSystem.price_for(glowing, cycle, config)
		print("%5d | %11d | %9d" % [cycle, combo_price, glow_price])
		_check(
			combo_price == EXPECTED_COMBO[cycle - 1],
			"Combo price at cycle %d." % cycle
		)
		_check(
			glow_price == EXPECTED_GLOW[cycle - 1],
			"Glow price at cycle %d." % cycle
		)
		_check(
			MarketSystem.price_for(neutral, cycle, config) == 10,
			"Unpriced phenotypes keep the base value."
		)

	_check(
		combo.cached_phenotype_dictionary == original_phenotypes,
		"Pricing must not modify the fish."
	)
	_check(
		config.gold == original_gold
		and config.long_fins == original_fins
		and config.glow == original_glow,
		"Pricing must not modify the authored schedule."
	)

	_test_forecasts(config)
	_test_rounding(config, combo)
	_test_maturity_lead(config)
	_test_config_validation(config)
	_finish()


func _test_forecasts(config: MarketConfig) -> void:
	_check(
		MarketSystem.upcoming_rises(1, config) == [
			{"phenotype": "Long", "cycle": 5, "cycles_until": 4},
		],
		"First rise is visible four cycles ahead."
	)
	_check(
		MarketSystem.upcoming_rises(4, config) == [
			{"phenotype": "Long", "cycle": 5, "cycles_until": 1},
			{"phenotype": "Glow", "cycle": 8, "cycles_until": 4},
		],
		"An imminent rise must not hide another actionable rise."
	)
	_check(
		MarketSystem.upcoming_rises(7, config) == [
			{"phenotype": "Glow", "cycle": 8, "cycles_until": 1},
		],
		"The forecast counts down to the actual change."
	)
	_check(MarketSystem.upcoming_rises(8, config).is_empty(), "No new rise after 8.")
	_check(MarketSystem.upcoming_rises(10, config).is_empty(), "No cycle-11 forecast.")


func _test_rounding(config: MarketConfig, combo: FishData) -> void:
	var fractional := config.duplicate(true) as MarketConfig
	fractional.base_value = 1
	fractional.gold[0] = 1.4
	fractional.long_fins[0] = 1.4
	_check(
		MarketSystem.price_for(combo, 1, fractional) == 2,
		"Round once at the end: 1 * 1.4 * 1.4 = 1.96 -> 2."
	)


func _test_maturity_lead(config: MarketConfig) -> void:
	var lifecycle := load("res://resources/lifecycle_config.tres") as LifecycleConfig
	_check(lifecycle != null, "Lifecycle resource loads.")
	if lifecycle == null:
		return

	var slow_fry := _fish("Silver", "Short", "Non-glow")
	slow_fry.age = 0
	slow_fry.life_stage = FishData.LifeStage.FRY
	var population: Array[FishData] = [slow_fry]

	for _step in range(config.forecast_horizon):
		var dead := AgingSystem.advance(population, lifecycle)
		_check(dead.is_empty(), "Fish survives the forecast horizon.")

	_check(
		slow_fry.life_stage == FishData.LifeStage.ADULT,
		"Slow fry can mature by a rise announced at the forecast horizon."
	)


func _test_config_validation(config: MarketConfig) -> void:
	var broken := config.duplicate(true) as MarketConfig
	broken.glow.pop_back()
	_check(not broken.validation_errors().is_empty(), "Reject missing schedule rows.")
	broken = config.duplicate(true) as MarketConfig
	broken.gold[0] = -1.0
	_check(not broken.validation_errors().is_empty(), "Reject negative demand.")


func _fish(color: String, fins: String, glow_value: String) -> FishData:
	var fish := FishData.new()
	fish.life_stage = FishData.LifeStage.ADULT
	fish.health = 100
	fish.cached_phenotype_dictionary = {
		"color": color,
		"fin length": fins,
		"glow": glow_value,
		"growth": "Slow",
	}
	return fish


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		push_error("FAIL: " + message)


func _finish() -> void:
	if _failures == 0:
		print("PASS: market prices, forecasts, rounding, and maturity lead.")
	else:
		printerr("FAIL: %d market checks." % _failures)
	quit(0 if _failures == 0 else 1)
