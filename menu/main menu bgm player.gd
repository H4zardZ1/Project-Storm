extends AudioStreamPlayer

#in seconds
@export var decay_period: float = 10.0 
#in seconds
@export var silent_period: float = 0.1
@export var loops: int = 1
@export var tracks_to_use: Array[AudioStream]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_rand.call_deferred()

func play_rand() -> void:
	play_i(randi_range(0, tracks_to_use.size()))

func play_i(i: int) -> void:
	volume_db = 0
	var t := 0.0
	var c := self.restart
	self.stream = tracks_to_use[i]
	if "loop_mode" in stream:
		if stream.loop_mode != 0:
			c = self.decay
			t = stream.get_length() - (stream.loop_end / stream.mix_rate)
	else:
		t = stream.get_length()
	var timer := get_tree().create_timer(t)
	timer.timeout.connect(c)
	play()


func decay():
	var tween := get_tree().create_tween().bind_node(self) 
	# There IS decibels for for no sound, it's just that it is negative infinity
	tween.tween_property(self, "volume_db", -100, decay_period).set_trans(tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(restart)

func restart():
	stop()
	get_tree().create_timer(silent_period).timeout.connect(play_rand)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
