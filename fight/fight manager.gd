extends Node



var turn_values := {}

var clashables: Array[FightClashable] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	create_turn_time()

func clear_turn_time():
	for key in turn_values.keys():
		turn_values.erase(key)

func create_turn_time():

	var speed_values : Array[int] = [40, 25, 10]
	#for i in range(clashables.size()):
		#clashable

	# let me build my nest in peace
	var sorter := {}
	for i in range(speed_values.size()):
		var speed := speed_values[i]
		for j in range(10, speed + 10, 10):
			var roll_result = randi_range(1, 10)
			if j > speed:
				roll_result -= (j - speed)
				if roll_result <= 0:
					continue
			roll_result += j
			if not sorter.has(roll_result):
				sorter[roll_result] = []
			if i not in sorter[roll_result]:
				sorter[roll_result].append(i)
	var v_sorted := sorter.keys()
	v_sorted.sort()
	for i in v_sorted:
		turn_values[i] = sorter[i]

# Advance the turn timer 
# func advance_turn_time():
# 	var last = turn_values.keys()[0]
# 	turn_values.erase(last)

func reset_turn_time():
	clear_turn_time()
	create_turn_time()

## Determines the cascade of clashes from starting node [param from].
func get_clash_net_of_clashable(from: FightClashable, other_ends: Array[FightClashable] = []):
	var result := {}
	for to in from.clash_targets:
		if to not in other_ends:
			other_ends.append(to)
			result[to] = get_clash_net_of_clashable(to, other_ends)
		else:
			result[to] = {}
	return result
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

# this is hopefully faster
# Determine the cascade of clashes using breadthfirst search (instead of depthfirst search)

# func get_clash_net_of_clashable_bfs(v: FightClashable):
#	var q = 
# 	var result:= {}
#	var vs := []
# 	
#	for to in v.clash_targets:
#		if to not in vs:
#			vs.append(to)
#			
# 	return result

#func make_attack(from: FightClashable, other_ends: Array[FightClashable] = []):
	#for target in from.clash_targets:
		#if target not in other_ends:
			#other_ends.append(target)
			#make_attack(target, other_ends)
		# # we've reached the end of the clash cascade; UNLEASH THEM
		#target.clash_receive(from)
		#
