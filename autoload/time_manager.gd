extends Node

signal cycle_advanced(cycle: int)

# Cycles that have elapsed since start of game
var cycle: int = 0


func advance_cycle() -> void:
	cycle+= 1
	cycle_advanced.emit(cycle)
