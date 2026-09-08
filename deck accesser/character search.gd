extends Control

const SORT_TYPES: Array[String] = [
	"name",
	"max_health",
]
@export_file("*tscn") var character_button_file: String
var character_button: PackedScene:
	get:
		return load(character_button_file)


@onready var grid: FlowContainer = $VC/SC/HFlowContainer
@onready var sort_option: OptionButton = $VC/SortOptions
var sort_option_cached: int
@onready var up_down_button: CheckButton = $VC/CheckButton
var sort_descending: bool

func _ready():
	load_characters.call_deferred()

var _dirty_warn_test_obj_invalid: bool = false
func load_characters():
	var test_obj: Node = character_button.instantiate()
	if not test_obj.get_property_list().any(func(d): return d.name == "displayed_character_stats"):
		# BAIL BAIL BAIL
		assert(_dirty_warn_test_obj_invalid, "Scene root node on file '{0}' does not have property 'displayed_character_stats'\
		The game will continue, but character search is disabled".format([character_button_file]))
		_dirty_warn_test_obj_invalid = true
		test_obj.free()
		return
	test_obj.free()
	for o in PlayerData.available_characters:
		var obj : Node = character_button.instantiate()
		obj.displayed_character_stats = o
		Signal(obj, "pressed").connect(Callable(PlayerData.add_characters_signal_ref).bind(o))
		grid.add_child(obj)


func sort_and_filter_characters():
	
	var children_copy := grid.get_children()
	
	# First, hide all children that do not fit the filters.
	for i in range(grid.get_children_count() - 1, -1, -1):
		var child := grid.get_child(i)
		if (child.displayed_character_stats as CharacterStats).name == $VC/FS.text:
			(child as Control).hide()
			children_copy.pop_at(i)
	

	if (sort_option.selected == sort_option_cached) and (up_down_button.button_pressed == sort_descending):
		return
	
	var need_sorting := false
	match up_down_button.button_pressed:
		0: # Standard. (Order of unlocked characters)
			if not sort_descending:
				children_copy.reverse()
				need_sorting = true
		
		_: # Any of the SORT_TYPES 
			if sort_option.selected <= SORT_TYPES.size():
				var to_sort: String = SORT_TYPES[sort_option.selected - 1]
				children_copy.sort_custom(
					(func(a, b): 
						return (
							(
								a[to_sort] > b[to_sort]
							) != up_down_button.button_pressed)
						)
				)
				need_sorting = true
	if need_sorting:
		for i in range(children_copy.size()):
			grid.move_child(children_copy[i], i)
	
	sort_option_cached = sort_option.selected
	sort_descending = up_down_button.button_pressed
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
