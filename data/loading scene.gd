extends Node

signal progress_changed(progress)
signal load_completed

@export_file("*.tscn") var load_screen_path: String = "res://menu/default loading screen.tscn"
var load_screen: PackedScene = load(load_screen_path)
var scene_file_to_load: String = ProjectSettings.get_setting("application/run/config", "res://menu/start/start menu.tscn")
var loaded_scene: PackedScene
var _progress: Array = []
## Time is in seconds.
@export_range(0.1, 1, 0.1, "or_greater") var time_between_load_checks: float = 0.2

var use_sub_threads: bool = true
# Called when the node enters the scene tree for the first time.
#func _ready():
	#call_deferred("load_scene")

func load_scene(custom_scene_file: String = "",) -> void:

	var local_scene_file_to_load: String
	if custom_scene_file:
		local_scene_file_to_load = custom_scene_file
	else:
		local_scene_file_to_load = scene_file_to_load


	var e := ResourceLoader.load_threaded_request(local_scene_file_to_load, "", use_sub_threads)
	if e:
		assert(false, "Failed to request to load file at '{path}'.".format({"path": local_scene_file_to_load}))
		return 

	# Request successful, now load the loading screen
	var new_loading_screen: Node = load_screen.instantiate()
	add_child(new_loading_screen)
	await Signal(new_loading_screen, "player_animation_finished")

	var load_status := ResourceLoader.load_threaded_get_status(local_scene_file_to_load, _progress)
	while load_status != ResourceLoader.THREAD_LOAD_LOADED:
		progress_changed.emit(_progress[0])
		match load_status:
			ResourceLoader.THREAD_LOAD_FAILED:
				assert(false, "Failed to load file at '{path}'. Yes, you're screwed.".format({"path": local_scene_file_to_load}))
				return
			ResourceLoader.THREAD_LOAD_IN_PROGRESS: 
				load_status = ResourceLoader.load_threaded_get_status(local_scene_file_to_load)
				progress_changed.emit(_progress)
				await get_tree().create_timer(time_between_load_checks).timeout
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# Reattempt to load the item, then wait
				assert(false, "(breakpoint, not a 'full' error state yet) Will reattempt to load file at '{path}'."\
				.format({"path": local_scene_file_to_load}))
				var err = ResourceLoader.load_threaded_request(local_scene_file_to_load)
				if err:
					assert(false, "Failed to request to load file at '{path}'. Yes, you're screwed.".format({"path": local_scene_file_to_load}))
					return
				await get_tree().create_timer(time_between_load_checks).timeout

	load_completed.emit()
	loaded_scene = ResourceLoader.load_threaded_get(local_scene_file_to_load)
	get_tree().change_scene_to_packed(loaded_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
