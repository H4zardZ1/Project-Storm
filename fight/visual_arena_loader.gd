extends Marker3D

# signal
signal visual_arena_path_changed(old_value, new_value)

# constants
const time_between_load_checks := 0.2
# variables
var visual_arena_path: String:
	get:
		return visual_arena_path
	set(value):
		visual_arena_path_changed.emit(visual_arena_path, value)
		visual_arena_path = value


# init

# ready
#func _ready():
	#pass

# functions

func load_visual_arena():
	var err := ResourceLoader.load_threaded_request(visual_arena_path)
	if err:
		assert(false, "Failed to request to load file at '{path}'.".format({"path": visual_arena_path}))
		# For now just do nothing.
		return

	var load_status := ResourceLoader.load_threaded_get_status(visual_arena_path)

	while load_status != ResourceLoader.THREAD_LOAD_LOADED:
		match load_status:

			ResourceLoader.THREAD_LOAD_FAILED:
				assert(false, "Failed to load file at '{path}'.".format({"path": visual_arena_path}))
				return 

			ResourceLoader.THREAD_LOAD_IN_PROGRESS: 
				load_status = ResourceLoader.load_threaded_get_status(visual_arena_path)
				await get_tree().create_timer(time_between_load_checks).timeout

			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# Reattempt to load the item, then wait
				assert(false, "(very expensive breakpoint) Will reattempt to load file at '{path}'."\
				.format({"path": visual_arena_path}))
				await get_tree().create_timer(time_between_load_checks).timeout
				err = ResourceLoader.load_threaded_request(visual_arena_path)
				if err:
					assert(false, "Failed to request to load file at '{path}'.".format({"path": visual_arena_path}))
					return

	# Loading is done, need to actually load the packed scene now
	var res := (ResourceLoader.load_threaded_get(visual_arena_path) as PackedScene)
	if not res:
		push_error("file at '{path}' not a valid packed scene.".format({"path": visual_arena_path}))
		return
	# First delete all children from this node
	for child in get_children():
		child.queue_free()
	# Then, add the loaded scene.
	var node := res.instantiate()
	add_child(node)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
