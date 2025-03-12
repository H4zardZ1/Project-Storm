extends Popup

@export_file("*.tscn") var packed_to_load: String = ""

# ready
func _ready():
	($TextModal/V/TextEdit as TextEdit).placeholder_text = "ENTER_SAVE_NAME_PLACEHOLDER"
	($TextModal/V/Label as Label).text = "ENTER_SAVE_NAME_TITLE"
	($TextModal/V/HBoxContainer/Cancel as BaseButton).pressed.connect(hide)



func _on_text_modal_submitted(text):
	PlayerData.save_name = text
	LoadingScene.load_scene(packed_to_load)
