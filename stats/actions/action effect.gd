extends Resource
class_name ActionEffect

func _init() -> void:
    pass

func connect_action(applied_to: Action):
    applied_to.about_to_use.connect(_on_use)
    _additional_connect_action(applied_to)
    # TO DO: Everything


## Override this function if you need additional connections with the action.
func _additional_connect_action(_applied_to: Action):
    pass

## Function to be called when the action is used.
func _on_use():
    pass
#
#func after_use():
    #pass
#
#func on_roll():
    #pass
#
#func on_clash():
    #pass
#
#func on_move(_arg: String = ""):
    #pass
#
#func on_draw():
    #pass
