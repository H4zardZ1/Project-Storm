extends HBoxContainer





var displayed_die_stats: ActionDie
@onready var speed_label: Label = $SpeedCost
@onready var roll_label: Label = $RollRange
@onready var die_text_label: Label = $DieText
@onready var attack: TextureRect = $AttackType
@onready var projectile: TextureRect = $ProjectileType
@onready var defense: TextureRect = $DefenseType
@onready var movement: TextureRect = $MovementType
# Called when the node enters the scene tree for the first time.
func _ready():
	speed_label.text = str(displayed_die_stats.speed_cost)

	var roll_text : String = "{roll1} - {roll2}".format(
		{"roll1": displayed_die_stats.roll_value_1,
		"roll2": displayed_die_stats.roll_value_2}
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
