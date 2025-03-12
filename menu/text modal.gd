extends PanelContainer

signal submitted(text)
var text_input: String:
	get:
		return text_edit.text


@onready var main_label: Label = $V/Label
@onready var submit_button: BaseButton = $V/HBoxContainer/Submit
@onready var cancel_button: BaseButton = $V/HBoxContainer/Cancel
@onready var text_edit: TextEdit = $V/TextEdit
# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass


func _on_submit():
	submitted.emit(text_edit.text)
