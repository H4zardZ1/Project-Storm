extends Node

func _unhandled_input(event: InputEvent):
	if event.is_action("ui_accept"):
		LoadingScene.load_scene()
