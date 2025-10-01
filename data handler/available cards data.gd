extends Node

# # constants
# const LOCAL_PATH = "res://stats/data/"
# const CARD_PATH = "actions/"
# const CHARACTER_PATH = "characters/"
# signals

# variables

## A Dictionary of mod id String as keys 
## that will contain [Array]s of [ActionStats].[br]
## [codeblock] { "mod_id_example": [ActionStats, ActionStats, ...]} [/codeblock]
var other_available_cards: Dictionary[String, Array] = {}
var local_available_cards: Array[ActionStats] = []
var available_cards: Array[ActionStats]:
	get = parse_available_cards

## A Dictionary of mod id String as keys 
## that will contain [Array]s of [CharacterStats].
## [codeblock] { "mod_id_example": [CharacterStats, CharacterStats, ...]} [/codeblock]
var other_available_characters: Dictionary[String, Array] = {}
var local_available_characters: Array[CharacterStats] = []
var available_characters: Array[CharacterStats]:
	get = parse_available_characters

## A Dictionary of mod id String as keys 
## that will contain [Array]s of [ActionStats].
## [codeblock] { "mod_id_example": [ActionStats, ActionStats, ...]} [/codeblock]
var other_default_available_cards: Dictionary[String, Array] = {}
@export var local_default_available_cards: Array[ActionStats] = []

## A Dictionary of mod id String as keys 
## that will contain [Array]s of [CharacterStats].
## [codeblock] { "mod_id_example": [CharacterStats, CharacterStats, ...]} [/codeblock]
var other_default_available_characters: Dictionary[String, Array] = {}
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

# func redeem_cards(cards: Array[ActionStats], mod_id: String = ""):
# 	for card_to_redeem in cards:
# 		if mod_id:
# 			if card_to_redeem not in other_available_cards:
# 				other_available_cards[mod_id].append(card_to_redeem)
# 		else:
# 			if card_to_redeem not in local_available_cards:
# 				local_available_cards.append(card_to_redeem)

# func save_file():
# 	var file := FileAccess.open("user://player/{0}/available.dat".format([PlayerData.save_name]), FileAccess.WRITE)
# 	var dict_to_save := { 
# 		"local" : [],
# 		"other" : {}
# 	} 
# 	# The reason why there IS a resource in the first place is because it can be loaded from disk easily
# 	# Which means that there is a path that points to the resource file itself.
# 	for card in local_available_cards:
# 		dict_to_save.local.append(card.resource_path)
# 	for key in other_available_cards:
# 		dict_to_save.other[key] = []
# 		for card in other_available_cards[key]:
# 			dict_to_save.other[key].append(card.resource_path)
# 	file.store_line(JSON.stringify(dict_to_save))
# 	dict_to_save = { 
# 		"local" : [],
# 		"other" : {}
# 	} 
# 	for character in local_available_characters:
# 		dict_to_save.local.append(character.resource_path)
# 	for key in other_available_characters:
# 		dict_to_save.other[key] = []
# 		for character in other_available_cards[key]:
# 			dict_to_save.other[key].append(character.resource_path)
# 	file.store_line(JSON.stringify(dict_to_save))
# 	file.close()

# func load_file():
# 	var file = FileAccess.open("user://player/{0}/available.dat".format([PlayerData.save_name]), FileAccess.READ)
# 	var to_load = JSON.parse_string(file.get_line())
# 	for card in to_load.local:
# 		# Load the resource
# 		# Prefer reusing it over any other kind of resource handling
# 		var o := ResourceLoader.load(card)
# 		if typeof(o) != TYPE_NIL:
# 			# Try, at least
# 			local_available_cards.append(o)
# 	# TODO: modded stuff
# 	to_load = JSON.parse_string(file.get_line())
# 	for character in to_load.local:
# 		var o := ResourceLoader.load(character)
# 		if typeof(o) != TYPE_NIL:
# 			local_available_characters.append(o)
		
# 	file.close()
