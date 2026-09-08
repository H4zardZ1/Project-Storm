extends Resource
class_name ActionEffect

func _init() -> void:
    pass

func connect_action(applied_to: Action):
    applied_to.about_to_use.connect(_on_use)
    _additional_connect_action(applied_to)
    # TODO: Everything


## Override this function if you need additional connections with the action.
func _additional_connect_action(_applied_to: Action):
    pass

## Function to be called when(before) the action is used.
func _on_use():
    pass
# ## Function to be called after the action is resolved.
#func after_use():
    #pass

# ## Function to be called when
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
