extends HBoxContainer




@export_node_path("Label", "RichTextLabel") var roll_label_path: NodePath
var roll_label: Node:
	set(value):
		roll_label = value
	get:
		if not is_instance_valid(roll_label):
			roll_label = get_node(roll_label_path)
		return roll_label

@export_node_path("Label", "RichTextLabel") var die_text_label_path: NodePath
var die_text_label: Node:
	set(value):
		die_text_label = value
	get:
		if not is_instance_valid(die_text_label):
			die_text_label = get_node(die_text_label_path)
		return die_text_label

var displayed_die_stats: ActionDie
# Called when the node enters the scene tree for the first time.
func _ready():

	var roll_text : String = "{roll1} - {roll2}".format(
		{"roll1": displayed_die_stats.roll_value_1,
		"roll2": displayed_die_stats.roll_value_2}
	)
	roll_label.text = roll_text

	die_text_label.text = displayed_die_stats.passive_text
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
