extends Resource
class_name LevelPhase


@warning_ignore_start("unused_signal")
## Normally, this signal will never be emitted.
## Extend from this class and make it emit this signal if you want the level's phase to end on a certain condition.
signal phase_end()
@warning_ignore_restore("unused_signal")

@export var characters: Array[LevelCharacterWrapper] = []
## Disable this if you don't want the level to end when only enemies or allies remain.
@export var normal_end_condition := true


func on_phase_enter(o: FightManager):
	_on_phase_enter(o)


## Override this function to determine how does FightManager interact with certain game states in this particular level(e.g. rewards)
func _on_phase_enter(_o: FightManager):
	pass
