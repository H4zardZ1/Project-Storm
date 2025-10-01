extends PanelContainer

signal picked()

@export var cost_label: Label
@export var card_name_label: Label
@export var card_speed_label: Label
@export var card_text_label: RichTextLabel

@export var die_display_scene: PackedScene = null
@onready var die_display_container: BoxContainer = $VBoxContainer
var displayed_action : Action

func _ready():
	cost_label.text = var_to_str(displayed_action.play_point_cost)
	card_name_label.text = displayed_action.display_name
	card_text_label.text = displayed_action.passive_text
	card_speed_label.text = var_to_str(displayed_action.speed_cost)

	if not is_instance_valid(die_display_scene):
		assert(false, "file at '{0}' not a valid PackedScene".format([die_display_container.scene_file_path]))
		return
	if not die_display_scene.can_instantiate():
		assert(false, "cannot instantiate PackedScene at '{0}'".format([die_display_container.scene_file_path]))
		return

	for die in displayed_action.action_dice:
		var die_display: Node = die_display_scene.instantiate()
		die_display.displayed_die_stats = die
		die_display_container.add_child(die_display)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):


func _get_drag_data(_at_position: Vector2) -> Action:
	return displayed_action

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.is_same(displayed_action)

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	picked.emit()


