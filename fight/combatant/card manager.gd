extends Node
class_name ActionManager

enum PileStatusEnum {
	DEFAULT = 1, ## The *first* pile with this 
	VISIBLE = 2, ## Pile can be seen by the player.
	PLAYABLE = 4, ## Pile can be played from.
	PLAYABLE_PLAYER = VISIBLE + PLAYABLE, ## Pile can be played by the player. [code](PileStatusEnum.VISIBLE + PileStatusEnum.PLAYABLE)[/code]
}
# signals
signal drew(card: Action)
signal card_about_to_move(from: Array, to: Array, card: Action, arg: String)
signal card_moved(from: Array, to: Array, card: Action, arg: String)
# variables
var deck: Array[Action] = []
var hand: Array[Action] = []
var discard: Array[Action] = []

## A Dictionary that contains piles that can be moved to/from. 
## Each value should be of type Array[Action].
## "deck" and "hand" are reserved for this class's own hand and deck values.
var piles: Dictionary[String, Array] = {
	"deck" : deck, # since these are by-ref type, i can just do this
	"hand" : hand,
	"discard": discard
}
# default value is PileStatusEnum.VISIBLE
var piles_status: Dictionary[String, int] = {
	"hand": 0b111,
}

## A Dictionary that holds the limit of how many cards can be held by the pile it's named of.
## If a pile lacks its threshold value, or it is negative, there are no limits on how much cards the pile can hold.
var piles_threshold: Dictionary[String, int]= {
	"hand" : 8
}

# init
func _init():
	randomize()

# enter_tree

# ready (including onready variables)
#func _ready():
	#pass

# functions

# Lazy Fisher-Yates Shuffle: 
# I don't shuffle, I just draw from a random index in the deck
static func lazy_shuffle_indexing(size: int, amount: int) -> Array[int]:
	var result: Array[int] = []
	result.resize(amount)
	var i: int = 0
	for j in range(size - 1, size - 1 - amount, -1):
		result[i] = (randi_range(0, j))
		i += 1
	return result

static func lazy_shuffle_indexing_rng(size: int, amount: int, rng: RandomNumberGenerator) -> Array[int]:
	var result: Array[int] = []
	for i in range(size - 1, size - 1 - amount, -1):
		result.append(rng.randi_range(0, i))
	return result

static func remove_at_multiple(a: Array, indices: PackedInt64Array) -> Array:
	var indices_copy: PackedInt64Array = indices.duplicate()
	indices_copy.sort()
	return remove_at_multiple_unsafe(a, indices_copy)

static func remove_at_multiple_unsafe(a: Array, indices: PackedInt64Array) -> Array:
	var result: Array
	var i: int = 0
	var j: int = 0
	var k: int = 0
	result.resize(a.size() - indices.size())
	while k < result.size():
		if j == indices[i]:
			i += 1
			j += 1
			continue
		result[k] = a[j]
		j += 1
		k += 1
	return result

# this version destroys ordering on the elements below the shuffle
static func partial_shuffle(a: Array, start_from: int, amount: int) -> void:
	start_from = mini(a.size(), start_from)
	amount = mini(mini(a.size() - 1, start_from), amount)
	for i in range(start_from - 1, start_from - 1 - amount, -1):
		var next_index = randi_range(0, i)
		var temp = a[i]
		a[i] = a[next_index]
		a[next_index] = temp

static func partial_shuffle_rng(a: Array, start_from: int, amount: int, rng: RandomNumberGenerator) -> void:
	start_from = mini(a.size(), start_from)
	amount = mini(mini(a.size() - 1, start_from), amount)
	for i in range(start_from - 1, start_from - 1 - amount, -1):
		var next_index = rng.randi_range(0, i)
		var temp = a[i]
		a[i] = a[next_index]
		a[next_index] = temp


## Note: This function creates a new Pile if such a Pile doesn't exist.
func get_pile_by_name(pile_name: String) -> Array:
	if pile_name not in piles:
		piles[pile_name] = []
	return piles[pile_name]

func get_pile_status_or_default(pile_name: String) -> int:
	return piles_status.get(pile_name, PileStatusEnum.VISIBLE)

func get_pile_threshold_by_name(pile_name: String) -> int:
	return piles_threshold.get(pile_name, -1)

func move_cards_random(amount :int, from_pile_name: String, to_pile_name: String, arg: String = ""):
	var to_pile: Array
	var from_pile: Array
	var to_pile_threshold :int
	var move_limit: int

	from_pile = get_pile_by_name(from_pile_name)
	if from_pile.is_empty():
		print("Pile '{pile}' has no cards to draw from".format({"pile": from_pile}))
		return

	to_pile = get_pile_by_name(to_pile_name)
	to_pile_threshold = get_pile_threshold_by_name(to_pile_name)

	if to_pile_threshold == -1:
		move_limit = to_pile.size()
	else:
		move_limit = to_pile_threshold - to_pile.size()
	if amount < 0:
		amount = move_limit
	else: 
		amount = min(amount, move_limit)

	partial_shuffle(from_pile, from_pile.size(), amount)
	for i in range(amount): 
		card_about_to_move.emit(from_pile_name, to_pile_name, from_pile[i], arg)
		var move_target: Object = from_pile.pop_at(i)

		to_pile.append(move_target)

		if (from_pile_name == "deck") and (to_pile_name == "hand") and (arg == ""):
			drew.emit(move_target)
		card_moved.emit(from_pile_name, to_pile_name, move_target, arg)
	return	

func move_cards_by_indices(to_move_indices: Array[int], from_pile_name: String, to_pile_name: String, \
arg: String = ""):
	var from_pile: Array = get_pile_by_name(from_pile_name)
	if from_pile.is_empty():
		print("Pile '{pile}' has no cards to draw from".format({"pile": from_pile}))
		return

	var to_pile: Array = get_pile_by_name(to_pile_name)
	var to_pile_threshold :int = get_pile_threshold_by_name(to_pile_name)

	var move_limit: int
	if to_pile_threshold == -1:
		move_limit = to_pile.size()
	else:
		move_limit = to_pile_threshold - to_pile.size()

	var moved_indices: Array[int] = []
	for i in to_move_indices:
		if moved_indices.size() >= move_limit:
			break
		var move_target_index: int = to_move_indices.pop_at(randi_range(0, to_move_indices.size()))
		var move_target: Object = from_pile[move_target_index]

		to_pile.append(move_target)
		if (from_pile_name == "deck") and (to_pile_name == "hand") and (arg == ""):
			drew.emit(move_target)
		card_moved.emit(move_target, arg)
		moved_indices.append(move_target_index)

	moved_indices.sort_custom(func(a, b): return a > b)
	for i in moved_indices:
		from_pile.remove_at(i)

func draw(amount: int):
	self.move_cards_random(amount, "deck", "hand")

func draw_by_indices(to_draw_indices: Array[int]):
	self.move_cards_by_indices(to_draw_indices, "deck", "hand")

#func discard_search(Array:to_discard_indices)

#func played
