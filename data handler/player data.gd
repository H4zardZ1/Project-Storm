extends Node

# constants
const PLAYER_SAVE_PATH = "user://player/{0}/player.dat"
const BACKUP_SAVE_PATH = "user://player/{0}/backup.dat"
# signals
signal played_characters_about_to_change()
signal played_characters_changed()

# variables
var default_maximum_characters: int = 7
var save_name: String = "chea"
var available_save_names: PackedStringArray = []
var played_characters: Array[PlayedCharacterWrapper] = []
var combat_level_entered: CombatLevel
# This is when the savefile is loaded (or created).
var time_started_save: float = 0
# This is how much time has elapsed inside the save.
var time_save: int = 0

# copied from available_cards_data 

# ## A Dictionary of mod id String as keys 
# ## that will contain [Array]s of [ActionStats].[br]
# ## [codeblock] { "mod_id_example": [ActionStats, ActionStats, ...]} [/codeblock]
# var other_available_cards: Dictionary[String, Array] = {}
# var local_available_cards: Array[ActionStats] = []
# var available_cards: Array[ActionStats]:
# 	get = parse_available_cards

# func parse_available_cards() -> Array[ActionStats]:
# 	var result: Array[ActionStats] = local_available_cards.duplicate()
# 	for key in other_available_cards:
# 		result.append_array(other_available_cards[key])
# 	return result

# ## A Dictionary of mod id String as keys 
# ## that will contain [Array]s of [CharacterStats].
# ## [codeblock] { "mod_id_example": [CharacterStats, CharacterStats, ...]} [/codeblock]
# var other_available_characters: Dictionary[String, Array] = {}
# var local_available_characters: Array[CharacterStats] = []
# var available_characters: Array[CharacterStats]:
# 	get = parse_available_characters

# func parse_available_characters() -> Array[CharacterStats]:
# 	var result: Array[CharacterStats] = local_available_characters.duplicate()
# 	for key in other_available_characters:
# 		result.append_array(other_available_characters[key])
# 	return result

# ## A Dictionary of mod id String as keys 
# ## that will contain [Array]s of [ActionStats].
# ## [codeblock] { "mod_id_example": [ActionStats, ActionStats, ...]} [/codeblock]
# var other_default_available_cards: Dictionary[String, Array] = {}
# @export var local_default_available_cards: Array[ActionStats] = []

# ## A Dictionary of mod id String as keys 
# ## that will contain [Array]s of [CharacterStats].
# ## [codeblock] { "mod_id_example": [CharacterStats, CharacterStats, ...]} [/codeblock]
# var other_default_available_characters: Dictionary[String, Array] = {}
# @export var local_default_available_characters: Array[ActionStats] = []

var pending_show_redeemed_cards : Array[ActionStats] = []
var pending_show_redeemed_characters : Array[CharacterStats]

func add_combatant_wrapper(w: PlayedCharacterWrapper):
	played_characters_about_to_change.emit()
	played_characters.append(w)
	played_characters_changed.emit()

#func remove_characters_signal(v):
	#
	#pass

func change_combatant_index(i: int, new_combatant: CharacterStats):
	played_characters_about_to_change.emit()
	if played_characters.size() >= i:
		played_characters[i].character = new_combatant
	played_characters_changed.emit()
	pass

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.

func save_data():
	if FileAccess.file_exists(PLAYER_SAVE_PATH.format([save_name])):
		DirAccess.copy_absolute(PLAYER_SAVE_PATH.format([save_name]), BACKUP_SAVE_PATH.format([save_name]))
	var file := FileAccess.open(PLAYER_SAVE_PATH.format([save_name]), FileAccess.WRITE)
	var t := Time.get_unix_time_from_system()
	var dict_to_save := {
		"time_save": time_save - time_started_save + t,
		"played_characters": [],
		# "available_cards": {

		# },
		# "available_characters": {

		# }
	}
	for c in played_characters:
		var c_dict := {}
		c_dict.character = c.character.resource_path
		c_dict.combatant_name = c.combatant_name
		c_dict.passives = c.passives.map(_get_path_of_resource)
		c_dict.deck = c.deck.map(_get_path_of_resource)
		dict_to_save.played_characters.append(c_dict)

	# The reason why there IS a resource in the first place is because it can be loaded from disk easily
	# Which means that there is a path that points to the resource file itself.
	# Unfortunately if the path changes the saved resource would be lost.
	# This is not... exactly ideal.
	# UIDs are not completely exposed yet as of 4.5

	var available_cards := { 
		"local" : CardsData.local_available_cards.map(_get_path_of_resource),
		"other" : {}
	} 
	for key in CardsData.other_available_cards.keys():
		available_cards.other[key] = CardsData.other_available_cards[key].map(_get_path_of_resource)
	var available_characters := { 
		"local" : CardsData.local_available_characters.map(_get_path_of_resource),
		"other" : {}
	} 
	for key in CardsData.other_available_characters.keys():
		available_characters.other[key] = CardsData.other_available_characters[key].map(_get_path_of_resource)
	dict_to_save.available_cards = available_cards
	dict_to_save.available_characters = available_characters

	file.store_var(dict_to_save)
	file.close()

func _get_path_of_resource(res: Resource)-> String:
	return res.resource_path
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass


func load_data():
	var file := FileAccess.open(PLAYER_SAVE_PATH.format([save_name]), FileAccess.READ)
	var chosen_save_path := PLAYER_SAVE_PATH
	if not is_instance_valid(file):
		file = FileAccess.open(BACKUP_SAVE_PATH.format([save_name]), FileAccess.READ)
		if not is_instance_valid(file):
			return
		chosen_save_path = BACKUP_SAVE_PATH
	var to_load = file.get_var()
	var time_last_save = FileAccess.get_modified_time(chosen_save_path.format([save_name]))
	time_save = to_load.time_save
	for i in range(to_load.played_characters.size()):
		var c = to_load.played_characters[i]
		var cd := PlayedCharacterWrapper.new()
		cd.character = load(c.character)
		cd.combatant_name = c.combatant_name
		for passive in c.passives:
			cd.passives.append(load(passive))
		for action in c.deck:
			cd.deck.append(load(action))
		played_characters[i] = cd
	var available_cards = to_load.available_cards
	CardsData.local_available_cards.clear()
	for card in available_cards.local:
		# Prefer reusing the resource over any other kind of resource handling
		var o := ResourceLoader.load(card)
		if is_instance_valid(o):
			# Try, at least
			CardsData.local_available_cards.append(o)
	# TODO: modded stuff
	CardsData.local_available_characters.clear()
	var available_characters = to_load.available_characters
	for character in available_characters.local:
		var o := ResourceLoader.load(character)
		if is_instance_valid(o):
			CardsData.local_available_characters.append(o)
	
	time_started_save = Time.get_unix_time_from_system()
	# QUOTE IDEAS FOR KIPH TO SAY WHEN TIME HAS PASSED
	if time_started_save - time_last_save < -86400:
		print("RETURN_TIME_REVERSED_QUOTE") # Likely to be a system clock reversal for easter egg checking
		# "...Were my powers gone out of control?"
	elif time_started_save - time_last_save < -3600:
		print("RETURN_TIME_REVERSED_DAY_QUOTE") # hmm
		# "Last time you left it was hours later."
	elif time_started_save - time_last_save <= 0:
		print("RETURN_TIME_REVERSED_HOUR_QUOTE") # hmm
		# "It's as if you never left."
	elif time_started_save - time_last_save < 3600:
		print("RETURN_TIME_LESSTHANHOUR_QUOTE")
		# "Forgot something?"
	elif time_started_save - time_last_save < 86400:
		print("RETURN_TIME_TODAY_QUOTE")
		# "Welcome back. Did you have a nice rest?"
	elif time_started_save - time_last_save < (86400 * 2):
		print("RETURN_TIME_YESTERDAY_QUOTE")
		# "How was your last day?"
	elif time_started_save - time_last_save < (86400 * 7):
		print("RETURN_TIME_WEEK_QUOTE")
		# "How's your week going so far?"
	elif time_started_save - time_last_save < (86400 * 14):
		print("RETURN_TIME_YESTERWEEK_QUOTE")
		# "It's been a week since I've seen you"
	elif time_started_save - time_last_save < (86400 * 30):
		print("RETURN_TIME_MONTH_QUOTE")
		# "It's been weeks since I've seen you."
	elif time_started_save - time_last_save < (86400 * 365):
		print("RETURN_TIME_YEAR_QUOTE")
		# "Months pass like nothing. Welcome back."
	elif time_started_save - time_last_save < (86400 * 3650):
		print("RETURN_TIME_DECADE_QUOTE")
		# "Years pass like nothing. Welcome back."
	elif time_started_save - time_last_save < (86400 * 36500): # more than half of int32 btw
		print("RETURN_TIME_CENTURY_QUOTE")
		# "Decades pass like nothing. Mages can wait for an eternity, after all. Welcome back."
	else:
		print("RETURN_TIME_ENDLESS_QUOTE")
		# "It's been ages since I've seen you. Mages can wait for an eternity, after all. Welcome back."
	CardsData.load_file()