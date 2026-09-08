extends CanvasLayer

#signal player_start_animation_finished


@export var progress_bar: Range

@onready var animation_player: AnimationPlayer = $AnimationPlayer




func _ready():
	var parent: Node = get_parent()
	var parent_is_loading_node: bool = !parent.has_signal("load_completed")
	if parent.has_signal("progress_changed"):
		(parent.progress_changed as Signal).connect(self._on_loading_progress_changed)

	if parent_is_loading_node:
		(parent.load_completed as Signal).connect(self._on_loading_complete, 1)
	if parent.has_signal("load_failed"):
		(parent.load_failed as Signal).connect(self._on_loading_complete, 1)
	if not parent_is_loading_node:
		animation_player.play("RESET")
	

func _on_loading_progress_changed(new_value: float):
	progress_bar.set_value_no_signal(new_value)

func _on_loading_complete():
	#if animation_player.current_animation:
		#await animation_player.animation_finished
	animation_player.play("end_load")
	await animation_player.animation_finished
	self.queue_free()

func _on_animation_complete(_name: StringName):
	#player_start_animation_finished.emit()
	pass
