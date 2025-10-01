extends Resource
class_name LevelCharacterWrapper

@export var character: CharacterStats
@export var team: int
@export var passives : Array[CharacterPassiveContainer]
## The custom-written combatant AI. If none are provided, the game will give control to the player.
@export var director: Script = null
@export var deck: Array[ActionStats] = []