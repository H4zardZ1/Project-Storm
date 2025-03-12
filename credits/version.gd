extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	text = tr("Version {s}").format({
		"s": Engine.get_version_info().string
	})


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
