extends HBoxContainer





var displayed_die_stats: ActionDie
@export var speed_label: RichTextLabel
@export var roll_label: RichTextLabel
@export var die_text_label: RichTextLabel
@export var attack: TextureRect
@export var projectile: TextureRect
@export var defense: TextureRect
@export var movement: TextureRect
# Called when the node enters the scene tree for the first time.
func _ready():
	speed_label.text = str(displayed_die_stats.speed_cost)

	var roll_text : String = "{0} ~ {1}".format(
		[displayed_die_stats.roll_value_1, displayed_die_stats.roll_value_2]
	)
	roll_label.text = roll_text

	die_text_label.text = displayed_die_stats.passive_text
	attack.visible = displayed_die_stats.basic_types & 1
	defense.visible = displayed_die_stats.basic_types & 2
	movement.visible = displayed_die_stats.move_direction != Vector2.ZERO
	#projectile.visible = # TBD
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
