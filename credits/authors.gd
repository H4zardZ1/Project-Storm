extends GridContainer

const packed_card: PackedScene = preload("res://credits/authors card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in Engine.get_author_info():
		var card := packed_card.instantiate()
		# String.capitalize()
		card.get_node("Label").text = key.capitalize()
		for s in Engine.get_author_info()[key]:
			var n_label := Label.new()
			n_label.text = s
			card.add_child(n_label)
		add_child(card)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
