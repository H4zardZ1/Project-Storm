extends Node

signal progress_changed(progress)
signal load_completed
signal load_failed

@export_file("*.tscn") var load_screen_path: String = "res://menu/default loading screen.tscn"
#@export var skip_
var load_screen: PackedScene = load(load_screen_path)
var scene_file_to_load: String = ProjectSettings.get_setting("application/run/main_scene", "res://menu/start/start menu.tscn")
# var _backup_scene_file_to_load: String = "uid://c4bhqrmbo3iwx"
var loaded_scene: PackedScene
var _progress: Array = []
var _load_try: int = 0
var _max_load_tries: int = 7
var _request_try: int = 0
var _max_request_tries: int = 2
var _loading_animation_complete: bool
@export_range(0.1, 1, 0.1, "or_greater") var sec_between_load_checks: float = 0.2

var use_sub_threads: bool = true
# Called when the node enters the scene tree for the first time.
#func _ready():
	#call_deferred("load_scene")

func load_scene(custom_scene_file: String = "") -> void:

	var local_scene_file_to_load: String
	if custom_scene_file:
		local_scene_file_to_load = custom_scene_file
	else:
		local_scene_file_to_load = scene_file_to_load


	var e := ResourceLoader.load_threaded_request(local_scene_file_to_load, "", use_sub_threads)
	if e:
		assert(false, "Failed to request to load file at '{0}'.".format([local_scene_file_to_load]))
		return 

	# Request successful, now load the loading screen
	var new_loading_screen: Node = load_screen.instantiate()
	add_child(new_loading_screen)
	_loading_animation_complete = !new_loading_screen.has_signal("player_starting_animation_finished")
	if not _loading_animation_complete:
		(new_loading_screen.player_starting_animation_finished as Signal).connect(_on_loading_animation_start_complete, CONNECT_ONE_SHOT)
	var load_status := ResourceLoader.load_threaded_get_status(local_scene_file_to_load, _progress)
	while load_status != ResourceLoader.THREAD_LOAD_LOADED:
		progress_changed.emit(_progress[0])
		match load_status:
			ResourceLoader.THREAD_LOAD_FAILED:
				assert(false, "Failed to load file at '{0}'. (Try #{1})".format([local_scene_file_to_load, _load_try + 1]))
				_load_try += 1
				ResourceLoader.load_threaded_request(local_scene_file_to_load)
			ResourceLoader.THREAD_LOAD_IN_PROGRESS: 
				load_status = ResourceLoader.load_threaded_get_status(local_scene_file_to_load)
				progress_changed.emit(_progress)
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# Reattempt to load the item, then wait
				assert(false, "Unknown '{0}'. (Try #{1})".format([local_scene_file_to_load, _request_try + 1]))
				_request_try += 1
				ResourceLoader.load_threaded_request(local_scene_file_to_load)
		if _load_try > _max_load_tries or _request_try > _max_request_tries:
			assert(false, "Maximum load tries reached. Returning to previous scene.")
			load_failed.emit()
			_load_try = 0
			_request_try = 0
			return
		# Timers can only go as fast as a single frame
		#if sec_between_load_checks <= Engine.max_fps:
			#await get_tree().process_frame
		#else:
		await get_tree().create_timer(sec_between_load_checks).timeout
	if not _loading_animation_complete:
		await (new_loading_screen.player_starting_animation_finished as Signal)
	load_completed.emit()
	loaded_scene = ResourceLoader.load_threaded_get(local_scene_file_to_load)
	get_tree().change_scene_to_packed(loaded_scene)
	_load_try = 0
	_request_try = 0

func _on_loading_animation_start_complete():
	_loading_animation_complete = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

#func catch_load_fail():
	#if _try > max_tries:
	#elif (_try % _wait_a_frame_every) == 0:
	#else:
