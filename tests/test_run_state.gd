extends Node

const TEST_SEED := 12345
const STARTING_COUNT := 7

var _failures: int = 0
var _notifications: int = 0


func _ready() -> void:
	var registry := load("res://resources/trait_registry.tres") as TraitRegistry
	var lifecycle := load("res://resources/lifecycle_config.tres") as LifecycleConfig
	var market := load("res://resources/checkpoint_market.tres") as MarketConfig
	_check(registry != null and lifecycle != null and market != null, "Configs load.")
	if registry == null or lifecycle == null or market == null:
		_finish()
		return
	_check(market.validation_errors().is_empty(), "Market config is populated.")
	if not market.validation_errors().is_empty():
		_finish()
		return

	var run := RunState.new(registry, lifecycle, market)
	# Setup: this connection survives resets of the same RunState object.
	run.changed.connect(_on_run_changed)
	run.start_new_run(TEST_SEED)
	_check(_notifications == 1, "One notification after initialization.")
	_check(run.cycle == 1 and run.money == 0, "Fresh cycle and wallet.")
	_check(run.roster.size() == STARTING_COUNT, "Exactly seven starters.")
	_check(run.last_cycle() == 10, "Ten-cycle market defines the last cycle.")
	if run.roster.size() != STARTING_COUNT:
		_finish()
		return

	for fish in run.roster:
		_check(fish.life_stage == FishData.LifeStage.ADULT, "Starters are adults.")

	var original_mom := run.find_fish("fish_0")
	var original_dad := run.find_fish("fish_1")
	_check(original_mom != null and original_dad != null, "Guaranteed pair exists.")
	if original_mom == null or original_dad == null:
		_finish()
		return

	var notices_before := _notifications
	_check(run.breed_pair("missing", "fish_1") == null, "Reject missing parent.")
	_check(run.breed_pair("fish_0", "fish_0") == null, "Reject self-cross.")
	original_dad.sex = FishData.Sex.FEMALE  # Controlled test fixture.
	_check(run.breed_pair("fish_0", "fish_1") == null, "Reject same sex.")
	original_dad.sex = FishData.Sex.MALE
	original_mom.life_stage = FishData.LifeStage.OLD
	_check(run.breed_pair("fish_0", "fish_1") == null, "Reject old parent.")
	original_mom.life_stage = FishData.LifeStage.ADULT
	_check(_notifications == notices_before, "Rejected actions do not notify.")

	# Reverse click order must still record mother first.
	var child := run.breed_pair("fish_1", "fish_0")
	_check(child != null, "Valid pair breeds.")
	if child == null:
		_finish()
		return
	_check(child.id == "fish_7", "Invalid attempts consumed no IDs.")
	_check(child.lineage == ["fish_0", "fish_1"], "Lineage is mother, father.")
	_check(child.age == 0 and child.life_stage == FishData.LifeStage.FRY, "Newborn state.")
	_check(child.health == 100, "Newborn health.")
	_check(run.cycle == 1, "Breeding does not advance time.")
	_check(run.breed_pair(child.id, "fish_0") == null, "Reject a fry parent.")
	var first_genome := child.genome.alleles.duplicate(true)
	var first_sex := child.sex

	_check(run.breed_pair("fish_0", "fish_1") != null, "Second birth this cycle.")
	_check(run.breed_pair("fish_0", "fish_1") != null, "Third birth this cycle.")
	_check(run.roster.size() == RunState.ROSTER_CAPACITY, "Roster reaches ten.")
	notices_before = _notifications
	_check(run.breed_pair("fish_0", "fish_1") == null, "Reject eleventh fish.")
	_check(_notifications == notices_before, "Full roster rejection does not notify.")
	_check(run.roster.size() == RunState.ROSTER_CAPACITY, "Rejection adds no fish.")

	# Put a non-parent exactly at its last living age.
	var dying_fish := run.find_fish("fish_6")
	dying_fish.age = (
		lifecycle.fry_cycles + lifecycle.juvenile_cycles
		+ lifecycle.adult_cycles + lifecycle.old_cycles
	)
	dying_fish.life_stage = FishData.LifeStage.OLD
	_check(run.advance_cycle(), "Advance is allowed before the final cycle.")
	_check(run.cycle == 2 and child.age == 1, "Clock and age advance once.")
	_check(run.find_fish("fish_6") == null, "Death removes the fish.")
	_check(run.roster.size() == 9, "Death frees one slot.")
	var later_child := run.breed_pair("fish_0", "fish_1")
	_check(later_child != null, "Breeding resumes after a death.")
	if later_child != null:
		_check(later_child.id == "fish_10", "No ID reuse and no ID spent at capacity.")

	while run.can_advance_cycle():
		run.advance_cycle()
	_check(run.cycle == 10, "Stop at decision cycle ten.")
	var final_age := child.age
	notices_before = _notifications
	_check(not run.advance_cycle(), "Reject cycle eleven.")
	_check(run.cycle == 10 and child.age == final_age, "Rejected advance does not age fish.")
	_check(_notifications == notices_before, "Rejected advance does not notify.")

	# Test fixture only: selling will be the gameplay writer of money later.
	run.money = 999
	notices_before = _notifications
	run.start_new_run(TEST_SEED)
	_check(_notifications == notices_before + 1, "Reset emits once, without reconnecting.")
	_check(run.money == 0 and run.cycle == 1, "Reset clears money and clock.")
	_check(run.roster.size() == STARTING_COUNT, "Reset replaces the population.")
	_check(run.find_fish("fish_0") != original_mom, "New run has new fish objects.")
	var replay_child := run.breed_pair("fish_0", "fish_1")
	_check(replay_child != null, "Can breed after reset.")
	if replay_child != null:
		_check(replay_child.id == "fish_7", "ID sequence restarts only with a new run.")
		_check(replay_child.genome.alleles == first_genome, "Same seed reproduces first genome.")
		_check(replay_child.sex == first_sex, "Same seed reproduces sex roll.")

	var other_run := RunState.new(registry, lifecycle, market)
	other_run.start_new_run(TEST_SEED)
	other_run.money = 50  # Controlled test fixture, not an economy feature.
	_check(run.money == 0, "Separate runs do not share a wallet.")
	_check(other_run.find_fish("fish_0") != run.find_fish("fish_0"), "Separate fish objects.")
	_finish()


func _on_run_changed() -> void:
	_notifications += 1


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		push_error("FAIL: " + message)


func _finish() -> void:
	if _failures == 0:
		print("PASS: RunState initialization, breeding, capacity, aging, IDs, and reset.")
	else:
		printerr("FAIL: %d RunState checks." % _failures)
