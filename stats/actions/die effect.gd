extends Resource
class_name ActionDieEffect
## Effects that are applicable to a die.

@export var passive_text: String = "DIE_PASSIVE_PREVIEW_TITLE"

# init
func _init():
	pass

func connect_die(applied_to: ActionDie):
	# TODO: everything
	_additional_connect_die(applied_to)

## Override this function if you need additional connections with the resourced die.
func _additional_connect_die(_applied_to: ActionDie):
	pass
# functions
## Function to be called when the die is rolled.
func _on_roll():
	pass

## Function to be called when the effects of the die are resolved.
func _after_use():
	pass
	
## Function to be called when the die hits.
func _on_hit():
	pass

## Function to be called on when the die enters a clash.
func _enter_clash():
	pass

## Function to be called on after a clash.
func _after_clash():
	pass

## Function to be called when the die wins its clash.
func _on_clash_win():
	pass

## Function to be called when the die loses its clash.
func _on_clash_lose():
	pass
