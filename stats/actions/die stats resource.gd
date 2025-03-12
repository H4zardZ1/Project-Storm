extends Resource
class_name ActionDieStats
## A class to store the data of a die.
##
## This class stores data that are relevant for this game's dice.

# static funcs
#static func convert_text_to_die(file: String) -> ActionDieStats:

# signals

# values
@export_group("Type")
@export_flags("Attack", "Block") var basic_types: int = 0
@export var move_direction: Vector2 = Vector2(0.0, 0.0)
#@export var projectile = 0 # TBD, will most likely be Object

@export_group("Stats")
@export_range(0, 100, 1, "or_greater") var roll_value_1: int = 0
@export_range(0, 100, 1, "or_greater") var roll_value_2: int = 0 # just making sure there are no more than 2 roll values.
@export_range(0, 10, 1, "or_greater") var speed_cost: int = 0
var passive: Array[ActionDieEffect] = []
var passive_text: String = ""

@export_group("Visuals")
@export var cinematics = ""
@export var character_movement = ""
# {UP, DOWN, LEFT, RIGHT, FORWARD, BACKWARD, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_FORWARD, MOVE_BACKWARD,
#MOVE_GO_TO, AIM, FIRE} ?


# custom variables
