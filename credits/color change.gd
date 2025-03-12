extends Node

@export_color_no_alpha var bg_color_to: Color

@onready var bg_color_from: Color = ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color
", Color(0.302, 0.302, 0.302)) # Is it better to call this onready rather than doing this at init?
# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(bg_color_to)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _exit_tree():
	RenderingServer.set_default_clear_color(bg_color_from)
