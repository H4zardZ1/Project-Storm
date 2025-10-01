extends Node
class_name CombatantDirector

var current_fight: FightManager = null
var controlling: FightCombatant
var is_player_controlling: bool = false

func get_next_action() -> Dictionary:
	return {
		"action": null, # Action
		"main_target": null # FightCombatant
	}
