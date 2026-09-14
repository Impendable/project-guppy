class_name RunState
extends RefCounted

signal changed

const FIRST_CYCLE := 1
const ROSTER_CAPACITY := 10

#UI reads these. Gameplay changes go through this objects methods
var roster: Array[FishData] = []
var money: int = 0
var cycle: int = FIRST_CYCLE

var _next_fish_id: int = 0
var _rng := RandomNumberGenerator.new()
var _registry: TraitRegistry
var _lifecycle_config: LifecycleConfig
var _market_config: MarketConfig

func _init(trait_registry: TraitRegistry, lifecycle: LifecycleConfig, market: MarketConfig) -> void:
	assert(trait_registry != null, "RunState needs a trait registry.")
	assert(lifecycle != null, "RunState needs lifecycle config.")
	assert(market != null, "RunState needs market config.")
	assert(market.validation_errors().is_empty(), "Invalid market config.")
	
	_registry = trait_registry
	_lifecycle_config = lifecycle
	_market_config = market


func start_new_run(run_seed: int) -> void:
	_rng.seed = run_seed
	money = 0
	cycle = FIRST_CYCLE
	
	#Create population before notifying the screen
	roster = RosterGenerator.generate(_registry, _rng)
	
	assert(not roster.is_empty(), "The starting roster was not generated.")
	assert(roster.size() < ROSTER_CAPACITY, "Start with a free breeding slot.")
	#The fresh generator uses consecutive IDs. This is not a save loader.
	for index in range(roster.size()):
		assert(roster[index].id == "fish_%d" % index)
	
	_next_fish_id = roster.size()
	changed.emit()


func last_cycle() -> int:
	return _market_config.cycle_count()


func can_advance_cycle() -> bool:
	return cycle < last_cycle()


func advance_cycle() -> bool:
	if not can_advance_cycle():
		return false
		
	var dead := AgingSystem.advance(roster, _lifecycle_config)
	for fish in dead:
		roster.erase(fish)
		
	cycle += 1
	changed.emit()
	return true


func find_fish(fish_id: String) -> FishData:
	for fish in roster:
		if fish.id == fish_id:
			return fish
	return null


func breeding_block_reason(first_id: String, second_id: String) -> String:
	var first := find_fish(first_id)
	var second := find_fish(second_id)
	
	if first == null or second == null or first_id == second_id:
		return "Select two different fish in this roster."
	if first.life_stage != FishData.LifeStage.ADULT or second.life_stage != FishData.LifeStage.ADULT:
		return "Both parents must be adults."
	if first.sex == second.sex:
		return "Select one female and one male."
	if roster.size() >= ROSTER_CAPACITY:
		return "Roster full. Free a slot before breeding!"
	return ""


func breed_pair(first_id: String, second_id: String) -> FishData:
	#Reject before consuming an Id or a random number
	if not breeding_block_reason(first_id, second_id).is_empty():
		return null
	
	var mom := find_fish(first_id)
	var dad := find_fish(second_id)
	
	if mom.sex == FishData.Sex.MALE:
		var swap := mom
		mom = dad
		dad = swap
	
	var offspring := BreedingSystem.make_offspring(mom, dad, _allocate_fish_id(), _registry, _rng)
	roster.append(offspring)
	changed.emit()
	return offspring


func _allocate_fish_id() -> String:
	var allocated_id := "fish_%d" % _next_fish_id
	_next_fish_id += 1
	return allocated_id
