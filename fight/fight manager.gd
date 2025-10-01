extends Node
class_name FightManager

signal new_round()
signal new_phase()
signal combat_ended()

signal clash_target_added(from, to)
## Emitted if and when the clash starts.
## This means that this does not emit when all clashes in the graph fails.
signal clash_starting(clashables: Array[FightClashable])
signal time_advanced(t)
## Note: state is from [param to]'s PoV; This emits multiple times on complex clashes. Make sure to check from and to.
signal clash_triggered(from, to, state: int)
## Emitted once, after all [signal clash_triggered] triggers on the clash network.
signal clash_ended(clashables: Array[FightClashable])
signal die_about_to_roll(die: ActionDie)
signal die_rolled(die: ActionDie, nat_roll: int)
signal combatant_died(who: FightCombatant)
signal combatant_damaged(who: FightCombatant, amount: int)

var turn_values: Dictionary[int, Array]= {}

@export var card_handler: Control = null
@export var friendly_tab: Control = null
@export var enemy_tab: Control = null
@export var card_display_scene: PackedScene = null
@export var default_combatant_scene: PackedScene = preload("uid://c0y17lppq3s42")
@export var character_tab_scene: PackedScene = preload("uid://q5h8o6k18lrw")
@export var test_level: CombatLevel = null

var held_action: Action

var clashables: Array[FightClashable] = []
var combatants: Array[FightCombatant] = []

var normal_phase_end_condition := true
var normal_combat_end_condition := true
# This is meant to store data to be read later.
var d : Dictionary = {}

var selected_combatant: FightCombatant
var player_is_controlling_until: int
var next_phase: int = 0

func _ready() -> void:

	# We'd need to do this on a deferred call if we're going to use await
	_after_ready.call_deferred()

func _after_ready() -> void:
	load_player_combatants()
	load_phase()
	begin_fight()

func load_player_combatants():
	for played_data in PlayerData.played_characters:
		add_combatant(played_data.character, 0, played_data.passives, played_data.deck)

func load_phase():
	var level: CombatLevel = PlayerData.combat_level_entered
	if not is_instance_valid(level) and next_phase == 0:
		level = test_level
	if not is_instance_valid(level) and next_phase != 0:
		assert(false, "Unknown state of game: the loaded level '{0}' for combat is invalid presumably during combat.\n\
		Exiting combat due to error".format([PlayerData.combat_level_entered]))
		combat_ended.emit()
		return
	if next_phase >= level.phases.size(): # We're done here.
		combat_ended.emit()
		return
	var phase := level.phases[next_phase]
	for level_character in phase.characters:
		add_combatant(level_character.character, level_character.team, level_character.passives, level_character.deck, level_character.director)
		phase.phase_end.connect(new_phase.emit)
		next_phase += 1




func add_combatant(c: CharacterStats, team: int, passives: Array[CharacterPassiveContainer], deck: Array[ActionStats] = [], director: Script = null ):
	var o := default_combatant_scene.instantiate()
	if not is_instance_valid(o):
		assert(false, "failed to instantiate node at '{0}'\n\
		Exiting combat due to error".format(default_combatant_scene.resource_path))
		combat_ended.emit()
	o.speed = c.speed
	o.max_health = c.max_health
	o.health = c.max_health
	o.max_mental = c.max_mental
	o.mental = c.max_mental
	o.max_guard = c.max_guard
	o.attack_factor = c.attack_factor
	o.defense_factor = c.defense_factor
	o.max_play_points.append_array(c.max_play_points_each_level)
	o.team = team

	for passive in passives:
		if passive.passive_effects.get_instance_base_type() != "Node":
			continue
		var passive_o := Node.new()
		passive_o.set_script(passive.passive_effects)
		o.add_child(passive_o)
	
	if is_instance_valid(director):
		# yes this is downcasting. No I have no clue how else would I deal with it
		o.get_node("CombatantDirector").set_script(director)
	else:
		o.get_node("CombatantDirector").is_player_controlling = true
	
	if deck:
		o.get_node("ActionManager").deck.append_array(deck)
	
	var character_tab := character_tab_scene.instantiate()
	# (character_tab.targetted_by as Signal).connect(_on_character_targetted_by_player.bind(o))
	character_tab.combatant = o
	if is_enemy(o):
		enemy_tab.add_child(character_tab)
	else:
		friendly_tab.add_child(character_tab)
	


	add_child(o)


func begin_fight() -> void:
	randomize()
	create_turn_time()

func clear_turn_time():
	for key in turn_values.keys():
		turn_values.erase(key)

func create_turn_time():
	for c in combatants:
		var speed := c.speed
		for j in range(10, speed + 10, 10):
			var roll_result = randi_range(1, 10)
			if j > speed:
				roll_result -= (j - speed)
				if roll_result <= 0:
					continue
			roll_result += j
			if not turn_values.has(roll_result):
				turn_values[roll_result] = []
			if c not in turn_values[roll_result]:
				turn_values[roll_result].append(c)

# func _on_character_targetted_by_player(first_target: FightClashable, card: Action):

# lower speed value is faster
func insert_turn_time(speed: int, from: FightClashable, targets: Array[FightClashable] = []):
	for target in targets:
		if target in from.clash_targets:
			continue
		from.clash_target_added.emit(target)
		clash_target_added.emit(from, target)
		target.clash_targets.append(from)
		from.clash_targets.append(target)
	if speed == 0:
		if (from is FightCombatant) and targets.is_empty():
			take_control(from)
		elif (from is FightClashable) and ((from as FightClashable).ready_clash_die.basic_types & 1):
			make_attack(from)
		return
	if speed not in turn_values:
		turn_values[speed] = []
	if from not in turn_values[speed]:
		turn_values[speed].append(from)

# clear the old targets, save it in case (so non-new targets won't resend the signal until it is properly removed, and then re-added later on)
func update_targets(at: FightClashable, new_targets: Array[FightClashable] = []):
	var old_targets := at.clash_targets.duplicate()
	for i in range(old_targets.size() - 1, -1, -1):
		var keep: bool = false
		for j in range(new_targets.size() -1, -1, -1):
			if new_targets[j] == old_targets[i]:
				keep = true
				new_targets.pop_at(j)
				break
		if not keep:
			at.clash_targets.pop_at(i)
			old_targets.pop_at(i)
	for target in new_targets:
		at.clash_targets.push_back(target)
		clash_target_added.emit(at, target)


# Advance the turn timer 
func advance_turn_time():
	var last = turn_values.keys().reduce(_get_lowest, INF)
	var objs := turn_values[last] 
	for o in objs:
		if o is FightCombatant:
			take_control(o)
		elif (o is FightClashable) and ((o as FightClashable).ready_clash_die.basic_types & 1):
			make_attack(o)
	turn_values.erase(last)
	for c in clashables:
		if c.speed_value > 0:
			c.speed_value -= last
	if turn_values.is_empty():
		create_turn_time()
		new_round.emit()
		if normal_phase_end_condition:
			check_phase_end()
		if normal_combat_end_condition:
			check_combat_end()
	time_advanced.emit(last)

func _get_lowest(accum, n):
	return min(accum, n)

func reset_turn_time():
	clear_turn_time()
	create_turn_time()

func check_phase_end():
	for combatant in combatants:
		if (combatant.team != 0) != (combatants[0].team != 0):
			return
	new_phase.emit()

func check_combat_end():
	for combatant in combatants:
		if combatant.team == 0:
			return
	combat_ended.emit()

## Determines the cascade of clashes if the node [param from] would start its clash.
## Returns a dictionary that contains two arrays: [br]
## - [code]"clashables"[/code] is an Array of FightClashables that would be in the clash(including [param from]).[br]
## - [code]"clashes"[/code] is an Array of pairs of FightClashables (in Arrays) that clash against each other.
func get_clashes_from_clashable(from: FightClashable) -> Dictionary:
	var result := {}
	var clashes := []
	var vs: Array[FightClashable] = [from]
	var i := 0
	while i < vs.size():
		var v := vs[i]
		# if v.can_clash:
		for to in v.clash_targets:
			if not (clashes.has([v, to]) or clashes.has([to, v])):
				clashes.append([v, to])
			if (to not in vs) and (to.can_clash()): 
				vs.append(to)
		i += 1
	result["clashes"] = clashes
	result["clashables"] = vs
	return result

	# online graph traversal bfs algorithm for all vertices AND edges
	# queue form is better for the ideal output form
	# why bfs? this is what happens with dfs:
		# a acts -> b reacts to clash a -> c reacts to clash b -> d reacts to clash a... why is d reacting AFTER c
	# TODO: this is probably not the ideal form for outputing the edges but this is way good enough for tens of elements i hope
	# then again: 1. this form has easy conversion for make_clash() calls
	# 2. you're basically turning a square to a triangle- and hundreds of "pointers" are still tiny for the ram

# Determines what should determine the [param who]'s next action.
func take_control(who: FightCombatant):
	if who.get_node("CombatantDirector").is_player_controlling:
		var sorted_speed := turn_values.keys()
		sorted_speed.sort()
		var player_ended_control := false
		for speed in sorted_speed:
			var objs := turn_values[speed] 
			for o in objs: 
				if o.get_node("CombatantDirector").is_player_controlling:
					player_ended_control = true
			if player_ended_control:
				break
			player_is_controlling_until = speed


	else:
		# Combatant wants to control the thing itself
		insert_turn_time(who.speed_value, who, who.get_node("CombatantDirector").get_next_action().main_target)

		pass
	

func see(which: ActionManager):

	for child in card_handler.get_children():
		child.queue_free()
	
	for card in which.hand:
		var o := card_display_scene.instantiate()
		# (o.picked as Signal).connect(set.bind("held_action", card))
		# 
		
		o["displayed_action"] = card
		card_handler.add_child(o)
	
	#card_handler.hand_completed()
		
func see_end():
	card_handler.visible = false

func roll_die(die: ActionDie) -> int:
	die_about_to_roll.emit(die)
	var nat_roll_value : int = randi_range(die.roll_value_1, die.roll_value_2)
	die_rolled.emit(die, nat_roll_value)
	return nat_roll_value

func roll_clashable(o: FightClashable):
	if !is_instance_valid(o.ready_clash_die):
		push_error("'{0}' does not have die to roll (how did this get to this point)".format([o]))
		return
	o.total_roll_value = roll_die(o.ready_clash_die)
	for bonus_key in o.roll_value_bonuses:
		match typeof(o.roll_value_bonuses[bonus_key]):
			TYPE_INT, TYPE_FLOAT:
				o.total_roll_value += o.roll_value_bonuses[bonus_key]
			TYPE_ARRAY:
				for n in o.roll_value_bonuses[bonus_key]:
					o.total_roll_value += n
			TYPE_CALLABLE:
				o.total_roll_value = o.roll_value_bonuses[bonus_key].call(o.total_roll_value)
			_:
				assert(false, "Unable to process type '{0}' into an int, ignoring '{1}' as a bonus on roll".format(
					[type_string(typeof(o.roll_value_bonuses[bonus_key])), bonus_key]
				))
	o.has_rolled = true

func make_attack(from: FightClashable):
	var c := get_clashes_from_clashable(from)
	var clashing_targets: Array[FightClashable] = []
	for target in c["clashables"]:
		if (is_same(target, from)) or (!target.can_clash()):
			continue
		clashing_targets.append(target)
		target.roll_value_bonuses["speed_penalty"] = -target.speed_value
		
	if clashing_targets.size() > 0:
		clash_starting.emit(clashing_targets)
	if not from.has_rolled:
		roll_clashable(from)
	for target in clashing_targets:
		if not target.has_rolled:
			roll_clashable(target)
	for clash in c["clashes"]:
		clash[0].clash_started.emit(clash[1])
		clash[1].clash_started.emit(clash[0])
		make_clash(clash[0], clash[1])
	clash_ended.emit(clashing_targets)
	

func make_clash(from: FightClashable, to: FightClashable):
	var clash_result: int = FightClashable.ClashState.LOST
	if to.speed_value > to.response_threshold or !is_instance_valid(to.ready_clash_die):
		clash_triggered.emit(from, to, FightClashable.ClashState.FAILED)
		if to is FightCombatant:
			combatant_hit(from, to)
		return
	if not to.has_rolled:
		roll_clashable(to)
	if to.total_roll_value == from.total_roll_value:
		clash_result = FightClashable.ClashState.TIED
	elif to.total_roll_value > from.total_roll_value:
		clash_result = FightClashable.ClashState.WON
	
	clash_triggered.emit(from, to, clash_result)
	if to is FightCombatant and FightClashable.ClashState.LOST and (to.ready_clash_die.basic_types & 1):
		combatant_hit(from, to)
	elif from is FightCombatant and FightClashable.ClashState.WON and (to.ready_clash_die.basic_types & 1):
		combatant_hit(to, from)

func is_enemy(who: FightCombatant):
	return who.team != 0

func combatant_hit(by: FightClashable, to: FightCombatant):
	by.pending_attack_successful.emit(to)
	to.hit.emit(by)
	var damage_factor := maxi((by.attack_factor - to.defense_factor), 1)
	var projected_damage := (by.total_roll_value - to.total_roll_value * (to.ready_clash_die.basic_types & 2)) * damage_factor

	if projected_damage > 0:
		combatant_damage(to, projected_damage)
	by.attack_injured.emit(to, projected_damage)
	to.hit_damaged.emit(by, projected_damage)
	
func combatant_damage(who: FightCombatant, amount: int):
	who.guard -= amount
	who.health -= amount
	combatant_damaged.emit(who, amount)
	who.damaged.emit(amount)
	if who.health < 0:
		combatant_die(who)

func combatant_die(who: FightCombatant):
	combatant_died.emit(who)
	who.died.emit()
	combatants.erase(who)

## A safer way of removing [param who]. Kills [param who] if it is still in the game, and then queues it for deletion.
func combatant_remove(who: FightCombatant):
	if who in combatants:
		combatant_die(who)
	who.queue_free()