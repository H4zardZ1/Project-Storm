extends FightClashable
class_name FightCombatant

#region FightManager Signals
# these signals are technically emitted not here, but instead mostly by FightManager
# still, it's here so that various functionalities don't have to listen in to FightManager for things that require only owner-related signals
# (e.g. "This Combatant: When Hit: 'foo'")
@warning_ignore_start("unused_signal")
## Emitted when a [FightClashable] has hit this combatant BEFORE they are damaged.
## This is emitted AFTER the by's [signal pending_attack_successful]
signal hit(by)
## Emitted after this combatant takes damage.
## If this is caused by a [FightClashable], this is emitted before their [signal attack_injured].
signal damaged(amount: int)
## Emitted when a Fightclashable has hit and damaged this combatant. This is emitted after by's [signal attack_injured] (this means that this is emitted after [signal damaged])
signal hit_damaged(by: FightClashable, amount: int)
## Emitted when this combatant dies from any reason (reached 0 health, Level Phase trigger, etc...)
signal died()
@warning_ignore_restore("unused_signal")
#endregion

enum ExcessEmotionLimitType {
	LAST,
	FIRST,
	CYCLE,
	MIRROR
}

var speed: int = 10
var max_health: int
var health: int 
var max_mental: int
var mental: int
var max_guard: int
var guard: int 

var max_play_points: Array[int] = [5, 5, 5, 5, 5, 5]
var current_max_play_points: int:
	get:
		return max_play_points[level - 1]
var play_points: int
var max_level: int:
	get:
		return max_play_points.size()
var level: int
var emo: int = 0

var emotion_limit: Array[int] = [3, 4, 5, 6, 7]
var current_emotion_limit: int:
	get:
		if level == max_play_points.size():
			return -1
		return emotion_limit[level - 1]
var excess_type: int = ExcessEmotionLimitType.LAST
var combatant_name: String

var damage_bonuses: Dictionary[int, Array] = {}

var team: int

# func play_action(action: Action, targets: Array[FightClashable]):
	
#     play_points = maxi(0, play_points - action.play_point_cost)
#     speed_value = action.speed_cost
#     played_action.emit(action)

# func receive_attack(by: FightClashable):
# 	var damage_factor = 

	


# func play_die(die: ActionDie):
#     if die.speed_cost > 0:
		
	
