extends Node

# constants

# signals
signal played_characters_changed()

# variables
var default_maximum_characters: int = 7
var save_name: String = "chea"
var played_characters: Array[CharacterStats] = []

func add_characters_signal(v):
	match typeof(v):
		TYPE_STRING:
			add_characters_signal_s(v)
			return
		TYPE_OBJECT:
			if v is CharacterStats:
				add_characters_signal_ref(v)
				return
			push_error("Cannot process object {v}".format({"v": v}))
		_:
			push_error("Cannot process value {v}".format({"v": v}))

func add_characters_signal_s(s: String):
	played_characters.append(ResourceLoader.load(s))
	played_characters_changed.emit()

func add_characters_signal_ref(ref: CharacterStats):
	played_characters.append(ref)
	played_characters_changed.emit()

#func remove_characters_signal(v):
	#
	#pass

func remove_characters_signal_index(i: int):
	played_characters.pop_at(i)
	played_characters_changed.emit()
	pass

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
