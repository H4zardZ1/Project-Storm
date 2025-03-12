extends Node
class_name FightClashable

# enums
enum ClashState {
	LOST,
	WON,
	TIED
}
# constants

# signals
signal clash_target_added(to)
## Emitted if the node can't clash with something else.
signal clash_response_failed(from, to)
## Emitted if and when the clash starts (didn't fail to respond).
signal clash_started(from, to)
# TBD
#signal clash_received(from, to)
## Emitted when the clash has been resolved.
signal clash_triggered(from, to, state)
signal die_about_to_roll()
signal die_rolled(nat_roll)
# variables
var ready_clash_die: ActionDie
var total_roll_value: int = 0

var has_rolled: bool = false
var clash_targets: Array[FightClashable] = []

## A Dictionary that will be filled with either int or Array[int] values.
var roll_value_bonuses: Dictionary = {
	"speed_penalty": 0,
	"flinch": 0
}

# Maybe initalize speed_value as a max-value int?
## How much "ticks" until this clashable fires(roughly)
var speed_value: int = -1
## How much "ticks", until this clashable fires, that this clashable can clash with things.
var response_threshold: int = 4




# enter_tree

# ready

# functions

func clash_receive(from:FightClashable):
	var clash_result: int = ClashState.LOST
	if speed_value > response_threshold or !is_instance_valid(ready_clash_die):
		clash_response_failed.emit(from, self)
		
		return 
	clash_started.emit(from, self)
	roll_value_bonuses["speed_penalty"] = -speed_value
	if not has_rolled:
		die_value_roll()
	if total_roll_value == from.total_roll_value:
		clash_result = ClashState.TIED
	elif total_roll_value > from.total_roll_value:
		clash_result = ClashState.WON
	
	clash_triggered.emit(from, self, clash_result)

func die_value_roll():
	die_about_to_roll.emit()
	total_roll_value = ready_clash_die.roll()
	die_rolled.emit(total_roll_value)
	for bonus_key in roll_value_bonuses:
		match typeof(roll_value_bonuses[bonus_key]):
			TYPE_INT:
				total_roll_value += roll_value_bonuses[bonus_key]
			TYPE_ARRAY:
				for n in roll_value_bonuses[bonus_key]:
					total_roll_value += n
			TYPE_CALLABLE:
				total_roll_value = roll_value_bonuses[bonus_key].call(total_roll_value)
			_:
				assert(false, "Unable to process '{type}' into an int.".format(
					{"type": type_string(typeof(roll_value_bonuses[bonus_key]))}
				))
	has_rolled = true

func clash_prepare():
	if (ready_clash_die.basic_types & 1):
		trigger_clash_attack()

func trigger_clash_attack():
	die_value_roll()
	for target in clash_targets:
		var clash_result: int = ClashState.LOST
		if not is_instance_valid(target):
			continue
		target.clash_receive(self)
		if total_roll_value == target.total_roll_value:
			clash_result = ClashState.TIED
		elif total_roll_value > target.total_roll_value:
			clash_result = ClashState.WON
		
		clash_triggered.emit(self, target, clash_result)


func add_clash_target(target: FightClashable):
	self.clash_targets.append(target)
	self.clash_target_added.emit(target)

func advance(speed: int):
	speed_value -= speed
	has_rolled = false
