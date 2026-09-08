extends Node
class_name FightClashable
## A node that represents something that can clash with something else during the fight.
##
## A node that represents something that can clash with something else during the fight.

# enums

enum ClashState {
	LOST,
	WON,
	TIED,
	FAILED ## FightClashable can't clash with something else.
}

# enum BonusOrder{
# 	ADD,
# 	MUL,
# 	MISC
# }

# constants

# # signals

#region FightManager Signals
# these signals are technically emitted not here, but instead mostly by FightManager
# still, it's here so that various functionalities don't have to listen in to FightManager for things that require only owner-related signals
# (e.g. "This Combatant: Start of Clash: 'foo'")
@warning_ignore_start("unused_signal")
signal clash_target_added(to: FightClashable)
# ## Emitted if the node can't clash with something else.

## Emitted if and when the clash starts (didn't fail to respond).
signal clash_started(with: FightClashable)
# # TBD
#signal clash_received(from)
## Emitted when the clash has been resolved.[br]
## Note: This emits multiple times on complex clashes.
signal clash_triggered(with: FightClashable, state: int)
signal die_about_to_roll()
signal die_rolled(nat_roll : int)
## Emitted when the Clashable has successfully attacked a character BEFORE they are damaged.
signal pending_attack_successful(target: FightCombatant)
## Emitted when the Clashable has successfully attacked and damaged a character.
signal damaged(target: FightCombatant, damage: int)
@warning_ignore_restore("unused_signal")
# signal-like Array[Callable]s
#endregion


# variables
var standby_dice: Array[ActionDie] = []
var ready_clash_die: ActionDie:
	get:
		if standby_dice.is_empty():
			return
		return standby_dice[0]
	set(value):
		standby_dice[0] = value
var total_roll_value: int = 0

var has_rolled: bool = false
var clash_targets: Array[FightClashable] = []
var attack_factor: int
var defense_factor: int
## A Dictionary that will be filled with either int or Array[int] values.
var roll_value_bonuses: Dictionary[int, Dictionary] = {
	0 : {
		"speed_penalty": 0,
		"flinch": 0,
	},
}


## How much "ticks" until this clashable fires(roughly)
var speed_value: int = -1
## How much "ticks", until this clashable fires, that this clashable can clash with things.
var response_threshold: int = 4

# init

# functions

func can_clash() -> bool:
	return speed_value <= response_threshold and standby_dice.size()



# func clash_receive(from:FightClashable):
# 	var clash_result: int = ClashState.LOST
# 	if speed_value > response_threshold or !is_instance_valid(ready_clash_die):
# 		clash_response_failed.emit(from, self)
		
# 		return 
# 	clash_started.emit(from, self)
# 	roll_value_bonuses["speed_penalty"] = -speed_value
# 	if not has_rolled:
# 		die_value_roll()
# 	if total_roll_value == from.total_roll_value:
# 		clash_result = ClashState.TIED
# 	elif total_roll_value > from.total_roll_value:
# 		clash_result = ClashState.WON
	
# 	clash_triggered.emit(from, self, clash_result)

# func die_value_roll():
# 	die_about_to_roll.emit()
# 	total_roll_value = ready_clash_die.roll()
# 	die_rolled.emit(total_roll_value)
# 	for bonus_key in roll_value_bonuses:
# 		match typeof(roll_value_bonuses[bonus_key]):
# 			TYPE_INT, TYPE_FLOAT:
# 				total_roll_value += roll_value_bonuses[bonus_key]
# 			TYPE_ARRAY:
# 				for n in roll_value_bonuses[bonus_key]:
# 					total_roll_value += n
# 			TYPE_CALLABLE:
# 				total_roll_value = roll_value_bonuses[bonus_key].call(total_roll_value)
# 			_:
# 				assert(false, "Unable to process '{type}' into an int.".format(
# 					{"type": type_string(typeof(roll_value_bonuses[bonus_key]))}
# 				))
# 	has_rolled = true

# func clash_prepare():
# 	if (ready_clash_die.basic_types & 1):
# 		trigger_clash_attack()

# func trigger_clash_attack():
# 	die_value_roll()
# 	for target in clash_targets:
# 		var clash_result: int = ClashState.LOST
# 		if not is_instance_valid(target):
# 			continue
# 		target.clash_receive(self)
# 		if total_roll_value == target.total_roll_value:
# 			clash_result = ClashState.TIED
# 		elif total_roll_value > target.total_roll_value:
# 			clash_result = ClashState.WON
		
# 		clash_triggered.emit(self, target, clash_result)


# func add_clash_target(target: FightClashable):
# 	self.clash_targets.append(target)
# 	self.clash_target_added.emit(target)

# func advance(speed: int):
# 	speed_value -= speed
# 	has_rolled = false
