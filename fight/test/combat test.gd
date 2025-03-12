extends CanvasLayer

@export var packed_test_combatant: PackedScene
@onready var combatant_grid: GridContainer = $CombatantContainer
@onready var clash_button: Button = $ButtonContainer/ClashButton
# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.

func create_combatant():
	var combatant := packed_test_combatant.instantiate()
	combatant_grid.add_child(combatant)
	clash_button.pressed.connect(combatant.clashable.clash_prepare)

#func _process(delta):
	#pass
