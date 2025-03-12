extends CanvasLayer

signal player_animation_finished

@export_node_path("Range") var progress_bar_path: NodePath
var progress_bar: Range:
	set(value):
		progress_bar = value
	get:
		if not is_instance_valid(progress_bar):
			progress_bar = get_node(progress_bar_path)
		return progress_bar

@onready var animation_player: AnimationPlayer = $AnimationPlayer




func _ready():
	var parent: Node = get_parent()

	if parent.has_signal("progress_changed"):
		(parent.progress_changed as Signal).connect(self._on_loading_progress_changed)

	if parent.has_signal("load_completed"):
		(parent.load_completed as Signal).connect(self._on_loading_complete, 1)

func _on_loading_progress_changed(new_value: float):
	progress_bar.set_value_no_signal(new_value)

func _on_loading_complete():
	if animation_player.current_animation:
		await animation_player.animation_finished
	animation_player.play("end_load")
	await animation_player.animation_finished
	self.queue_free()

func _on_animation_complete(_name: StringName):
	player_animation_finished.emit()
