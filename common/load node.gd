extends Node

@export_file("*.tscn") var packed_to_load: String = ""

func load_packed():
	LoadingScene.load_scene(packed_to_load)
