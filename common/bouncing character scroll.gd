extends ScrollContainer

var t: Tween = null
var pending_timer: SceneTreeTimer = null
@export var base_delay: float = 1.0
@export var speed: float = 25.0
@onready var l: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	tween_reset.call_deferred()
		

func tween_reset():
	var excess_len := l.size.x - size.x
	if excess_len <= 0:
		return
	t = create_tween()
	t.tween_property(self, "scroll_horizontal", excess_len, excess_len / speed).set_delay(base_delay)
	t.tween_property(self, "scroll_horizontal", 0, excess_len / speed).set_delay(base_delay)
	t.set_loops()

# Hmm...
func disturbed():
	if not is_instance_valid(t):
		return
	t.kill()
	if is_instance_valid(pending_timer):
		# 
		pending_timer.time_left = 0.0
	else:
		pending_timer = get_tree().create_timer(base_delay)
		pending_timer.timeout.connect(timer_timeout)

func timer_timeout():
	tween_reset()
	# Since I'm using instance validity on pending_timer, if I don't deref it, 
	# the node may not be able to accept any more "size" disturbances correctly
	pending_timer = null

func _on_focus_entered():
	if is_instance_valid(t):
		t.stop()

func _on_focus_exited():
	if is_instance_valid(t):
		t.play()
