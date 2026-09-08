extends ScrollContainer

var t: Tween = null
var pending_timer: SceneTreeTimer = null
@export var base_delay: float = 1.0
@export var speed: float = 25.0

func _ready():
	tween_reset.call_deferred()

func tween_reset():
	var max_x := 0.0
	for child in get_children():
		if child is not Control:
			continue
		max_x = maxf((child as Control).size.x, max_x)
		#max_x = maxf((child as Control).size.x + (child as Control).position.x, max_x)
	var excess_len := max_x - size.x
	if excess_len <= 0:
		return
	t = create_tween()
	if scroll_horizontal < 1:
		t.tween_property(self, "scroll_horizontal", excess_len, excess_len / speed).set_delay(base_delay)
		t.tween_property(self, "scroll_horizontal", 0, excess_len / speed).set_delay(base_delay)
		t.set_loops()
	elif scroll_horizontal > (excess_len - 1):
		t.tween_property(self, "scroll_horizontal", 0, excess_len / speed).set_delay(base_delay)
		t.tween_property(self, "scroll_horizontal", excess_len, excess_len / speed).set_delay(base_delay)
		t.set_loops()
	# Scroll in the middle, go to the far side
	elif scroll_horizontal < (excess_len / 2): # Left side
		t.tween_property(self, "scroll_horizontal", excess_len, (excess_len - scroll_horizontal) / speed).set_delay(base_delay)
		t.tween_callback(tween_reset.call_deferred).set_delay(base_delay)
	else: # Right side
		t.tween_property(self, "scroll_horizontal", 0, scroll_horizontal / speed).set_delay(base_delay)
		t.tween_callback(tween_reset.call_deferred).set_delay(base_delay)
	

# Hmm...
func disturbed():
	if not is_instance_valid(t):
		return
	t.kill()
	if is_instance_valid(pending_timer):
		pending_timer.time_left = base_delay
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
