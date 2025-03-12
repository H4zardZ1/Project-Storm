extends HBoxContainer

var left_text: String
var right_text: String
@onready var left_label: Label = $Label
@onready var right_label: Label = $S/Label
# Called when the node enters the scene tree for the first time.
func _ready():
	left_label.text = left_text
	right_label.text = right_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
