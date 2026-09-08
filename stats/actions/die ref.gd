extends RefCounted
class_name ActionDie

#region FightManager signals
# these signals are technically emitted not here, but instead mostly by FightManager
# still, it's here so that various functionalities don't have to listen in to FightManager for things that require only die-related signals
# (e.g. "On Roll: 'foo'")
signal about_to_roll()
signal rolled(value: int)
#endregion

const COPY_PROPERTIES: PackedStringArray = ["basic_types", "move_direction", "roll_value_1", "roll_value_2", "speed_cost", "passive", "passive_text",
"cinematics", "character_movement"]

var basic_types: int = 0
var move_direction: Vector2 = Vector2(0.0, 0.0)

var roll_value_1: int = 0
var roll_value_2: int = 0
var speed_cost: int = 0

var passive: Array[ActionDieEffect] = []
var passive_text: String = ""

var cinematics = ""
var character_movement = ""

## Additional effects that can be applied to the die.
## You can bypass this and edit the die itself(Plain stat changes).
var buff: Array = []

# Can accept dict, obj, nil
func _init(v = null) -> void:
	match typeof(v):
		TYPE_DICTIONARY:
			init_dict(v)
		TYPE_OBJECT:
			init_obj(v)
		TYPE_NIL:
			# print("Die ready to be edited.")
			pass
		_:
			push_warning("Cannot process variant '{0}' of type '{1}'.(The constructor should be able to accept creating new objects from null (i.e. no variables))".format([v, typeof(v)]))
	return

func init_dict(d: Dictionary) -> void:
	# var err_t := ""
	basic_types = d.basic_types
	move_direction = d.move_direction
	
	if d.has("roll_value") and (not(d.has("roll_value_1") or d.has("roll_value_2"))):
		roll_value_1 = d.roll_value
	else:
		roll_value_1 = d.roll_value_1
		roll_value_2 = d.roll_value_2
	speed_cost = d.speed_cost
	
	for p in d.passive:
		add_passive(p)
	
	cinematics = d.cinematics
	character_movement = d.character_movement
	
	# if err_t:
	# 	push_error(err_t)
	
	return

func init_obj(o: Object) -> void:
	var err_p : Array[String] = []
	for prop in COPY_PROPERTIES:
		if (prop in o) and (prop in self):
			if prop == "passive":
				for p in o[prop]:
					add_passive(p)
			else: 
				self[prop] = o[prop]
		elif not (prop in self):
			assert(false, "Property '{0}' not found in script that governs the type 'ActionDie'".format([prop]))
		else:
			err_p.append(prop)
	if not err_p.is_empty():
		push_error("Properties {0} not found in object '{1}'".format([
			err_p.reduce(_perror_init_obj), o
		]))

func _perror_init_obj(accum, t):
	if accum:
		return accum + ", '{0}'".format([t])
	else:
		return "'{0}'".format([t])

# TODO: add recursive duplicate setting
func duplicate() -> ActionDie:
	return ActionDie.new(self)

func add_passive(p: ActionDieEffect):
	p.connect_die(self)
	passive.append(p)

func roll(rng: RandomNumberGenerator = null) -> int:
	about_to_roll.emit()
	var result: int
	if is_instance_valid(rng):
		result = rng.randi_range(roll_value_1, roll_value_2)
	else:
		result = randi_range(roll_value_1, roll_value_2)
	rolled.emit()
	return result
