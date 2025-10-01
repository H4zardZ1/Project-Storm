extends RefCounted
class_name 	ActionDie

signal about_to_roll()
# Since Resource inherits RefCounted, and this also inherits RefCounted, the last common ancestor is RefCounted.
# WARNING: The plain copy may be a Resource that is used in a lot of scenes(and they may or may not be exclusive to scenes
# since this method is used to bypass Resource settings).
#var plain_copy: RefCounted

const COPY_PROPERTIES = ["basic_types", "move_direction", "roll_value_1", "roll_value_2", "speed_cost", "passive", "passive_text",
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

# Can accept dict and Obj
func _init(v = null) -> void:
	match typeof(v):
		TYPE_DICTIONARY:
			init_dict(v)
		TYPE_OBJECT:
			init_obj(v)
		TYPE_NIL:
			print("Die ready to be edited.")
		_:
			push_error("Cannot process variant '{0}' of type '{1}'.(The constructor should be able to accept creating new objects from null (i.e. no variables))".format([v, typeof(v)]))
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
	var err_p := []
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

func roll() -> int:
	about_to_roll.emit()
	var result: int = randi_range(roll_value_1, roll_value_2)
	return result
