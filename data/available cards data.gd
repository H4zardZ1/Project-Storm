extends Node

# constants
const LOCAL_PATH = "res://stats/data/"
const CARD_PATH = "actions/"
const CHARACTER_PATH = "characters/"
# signals

# variables

## A Dictionary of mod id String as keys 
## that will contain [Array] of [ActionStats].[br]
## [codeblock] { "directory/path/to/": ["file1.ini", "file2.ini", ...] } [/codeblock]
var other_available_cards: Dictionary = {}
var local_available_cards: Array[ActionStats] = []
var available_cards: Array[ActionStats]:
	get = parse_available_cards

## A Dictionary of mod id String as keys 
## that will contain [Array] of [CharacterStats].
var other_available_characters: Dictionary = {}
var local_available_characters: Array[CharacterStats] = []
var available_characters: Array[CharacterStats]:
	get = parse_available_characters

## A Dictionary of mod id String as keys 
## that will contain [Array] of [ActionStats].
var other_default_available_cards: Dictionary = {}
@export var local_default_available_cards: Array[ActionStats] = []

## A Dictionary of mod id String as keys 
## that will contain [Array] of [CharacterStats].
var other_default_available_characters: Dictionary = {}
@export var local_default_available_characters: Array[ActionStats] = []

func parse_available_cards() -> Array[ActionStats]:
	var result: Array[ActionStats] = local_available_cards.duplicate()
	for key in other_available_cards:
		result.append_array(other_available_cards[key])
	return result
	#for s in local_available_cards:
		#result.append("{local}{card}{file}".format({
			#"local": LOCAL_PATH,
			#"card": CARD_PATH,
			#"file": s
		#}))
	#for s in local_default_available_cards:
		#result.append("{local}{card}{file}".format({
			#"local": LOCAL_PATH,
			#"card": CARD_PATH,
			#"file": s
		#}))
	#for key in available_cards:
		#for s in available_cards[key]:
			#result.append("{key-as-path}{file}".format({
				#"key-as-path": key,
				#"file": s
			#}))
	#for key in default_available_cards:
		#for s in default_available_cards[key]:
			#result.append("{key-as-path}{file}".format({
				#"key-as-path": key,
				#"file": s
			#}))
	#return result
#
func parse_available_characters() -> Array[CharacterStats]:
	var result: Array[CharacterStats] = local_available_characters.duplicate()
	for key in other_available_characters:
		result.append_array(other_available_characters[key])
	return result
#func parse_available_characters() -> Array[String]:
	#var result: Array[String] = []
	#for s in local_available_characters:
		#result.append("{local}{character}{file}".format({
			#"local": LOCAL_PATH,
			#"character": CHARACTER_PATH,
			#"file": s
		#}))
	#for s in local_default_available_characters:
		#result.append("{local}{card}{file}".format({
			#"local": LOCAL_PATH,
			#"character": CHARACTER_PATH,
			#"file": s
		#}))
	#for key in available_characters:
		#for s in available_characters[key]:
			#result.append("{key-as-path}{file}".format({
				#"key-as-path": key,
				#"file": s
			#}))
	#for key in default_available_characters:
		#for s in default_available_characters[key]:
			#result.append("{key-as-path}{file}".format({
				#"key-as-path": key,
				#"file": s
			#}))
	#return result



# _ready. Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.

# _process. Called every frame. 'delta' is the elapsed time in seconds since the previous frame.
#func _process(delta):
	#pass

# functions
#func save_file():
	#var file = FileAccess.open(save_path, FileAccess.WRITE)

#func load_file():
	#var file = FileAccess.open(save_path, FileAccess.READ)
	
