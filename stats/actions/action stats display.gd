extends PanelContainer

@export_node_path("Label", "RichTextLabel") var cost_label_path: NodePath
var cost_label: Node:
	set(value):
		cost_label = value
	get:
		if not is_instance_valid(cost_label):
			cost_label = get_node(cost_label_path)
		return cost_label

@export_node_path("Label", "RichTextLabel") var card_name_label_path: NodePath
var card_name_label: Node:
	set(value):
		card_name_label = value
	get:
		if not is_instance_valid(card_name_label):
			card_name_label = get_node(card_name_label_path)
		return card_name_label

@export_node_path("Label", "RichTextLabel") var card_text_label_path: NodePath
var card_text_label: Node:
	set(value):
		card_text_label = value
	get:
		if not is_instance_valid(card_text_label):
			card_text_label = get_node(card_text_label_path)
		return card_text_label

@export_file("*.tscn") var die_display_path: String
@onready var die_display_container: BoxContainer = $VBoxContainer
var displayed_action_stats : ActionStats

func _ready():
	cost_label.text = displayed_action_stats.play_point_cost
	card_name_label.text = displayed_action_stats.display_name
	card_text_label.text = displayed_action_stats.passive_text

	var die_display_scene_file: PackedScene = load(die_display_path)
	if not is_instance_valid(die_display_scene_file):
		assert(false, "file at '{path}' not a valid PackedScene".format({"path": die_display_path}))
		return
	if not die_display_scene_file.can_instantiate():
		assert(false, "cannot instantiate PackedScene at '{path}'".format({"path": die_display_path}))
		return

	for die in displayed_action_stats.action_dice:
		var die_display: Node = die_display_scene_file.instantiate()
		die_display.displayed_die_stats = die
		die_display_container.add_child(die_display)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
