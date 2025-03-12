extends Panel

@onready var clashable: FightClashable = $FightClashable
@export var line_color := Color(0.5, 0.5, 0.5)
@export var line_width: float = 5.0
@export var die: ActionDieStats
@onready var label: Label = $Label

var won_count: int = 0
var tied_count: int = 0
var lost_count: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _ready():
	clashable.ready_clash_die = ActionDie.new(die)

func _get_drag_data(_at_position: Vector2):
	var control_curve := CurveControl.new()
	control_curve.color = line_color
	control_curve.line_width = line_width
	set_drag_preview(control_curve)
	return clashable

func _can_drop_data(_at_position, data):
	return typeof(data) == TYPE_OBJECT and (data is FightClashable)
func _drop_data(_at_position, data):
	clashable.add_clash_target(data)

func label_draw():
	label.text = "Rolled a {n}\nWon:{w}\nTied:{t}\nLost:{l}".format({
		"n": clashable.total_roll_value,
		"w": won_count,
		"t": tied_count,
		"l": lost_count
	})


func _on_fight_clashable_clash_triggered(_from, _to, state):
	won_count += int(state == FightClashable.ClashState.WON)
	tied_count += int(state == FightClashable.ClashState.TIED)
	lost_count += int(state == FightClashable.ClashState.LOST)
	label_draw.call_deferred()
