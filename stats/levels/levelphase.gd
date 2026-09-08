extends Resource
class_name LevelPhase
## A class that stores the data regarding a level's phase in the files.
##
## A class that stores the data regarding a level's phase in the viles.

@warning_ignore_start("unused_signal")
## Normally, this signal will never be emitted.
## Extend from this class and make it emit this signal if you want the level's phase to end on a certain condition.
signal phase_end()
@warning_ignore_restore("unused_signal")

@export var characters: Array[LevelCharacterWrapper] = []
## Whether the phase ends when only player's allies remain.
@export var normal_phase_end_condition := true
## Whether the fight ends DURING THIS PHASE when only player's enemies remain.
@export var normal_fight_end_condition := true

func on_phase_enter(o: FightManager):
	_on_phase_enter(o)


## Override this function to determine how does FightManager interact with certain game states in this particular phase(e.g. rewards)
func _on_phase_enter(_o: FightManager):
	pass
