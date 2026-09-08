extends Resource
class_name CharacterStats
## A class to store the data of a character in files.
##
## A class to store the data of a character in files.[br]
## [b]Note[/b]: [member resource_local_to_scene] will mostly be ignored for this class. See [FightCombatant]


#variables
@export var character_name: String = "chea"

@export_group("Stats")
@export var max_health: int = 100
@export var max_mental: int = 100
@export var max_guard: int = 40
@export var attack_factor: int = 3
@export var defense_factor: int = 1
@export var speed: int = 10
@export var max_play_points_each_level: Array[int] = [5, 5, 5, 5, 5, 5]
var max_level: int:
	get:
		return max_play_points_each_level.size()
## Card Tags, for exclusive cards.
@export var card_tags: Array[String] = []

@export_group("", "")
#@export var basic_passives array[] = [] # First, figure out the name
@export var extra_passive_num: int = 0

@export var character_3d_body_type: String = ""
