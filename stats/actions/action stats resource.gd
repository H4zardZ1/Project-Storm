extends Resource
class_name ActionStats
## A class to store the data of a card.
##
## This class stores data that are relevant for this game's cards.[br]
## [b]Note[/b]: The "Local to Scene" setting will mostly be ignored for this class. See [Action]

# variables
@export var display_name = ""

@export_group("Action Stats")
@export var play_point_cost: int = 0
## The speed cost of the card before it is used. There can be the gap between this card's use
## and the first die roll(if there is indeed a die).
@export var speed_cost: int = 0
## Exclusives: String tags. Strings directly in the array is OR for all strings.
## "-[lb]text[rb]" will make it instead available for anyone to use but [lb]text[rb].
@export var exclusive: Array[String] = []
# Passives. 
var passives: Array[ActionEffect] = [] 
var passive_text: String = ""

# TO DO: Visuals on the action itself will be triggered before dice visuals.
@export_group("Visuals")
@export var cinematics: String = "" 
@export var character_movement: String = "" 

@export_group("Dice")
## The array of dice themselves that is used when this card is used.
## A card does not necessarily contain dice.
@export var action_dice: Array[ActionDieStats] = []

# # init
# func _init():
# 	pass

# functions

