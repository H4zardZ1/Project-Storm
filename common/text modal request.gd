extends Resource
class_name TextModalRequest
## Request wrapper of the text modal server.
##
## Request wrapper of the text modal server.

@export var title := ""
@export var content := ""
@export var placement: Vector2
@export var is_stopping := true
var add_as_child_of: Node = null
@export_group("Modal Settings")
@export var use_default_modal_settings := true
@export var enter_duration := 1.0
@export var hover_in_duration := 0.8
@export var hover_depth := 0.2
@export var vanish_duration := 1.0
