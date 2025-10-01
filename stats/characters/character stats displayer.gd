extends VBoxContainer

## For translation stuff.
const stat_starfix = "STAT_"

const DISPLAYED_STATS: Array[String] = ["max_health", "max_mental", "max_guard", "attack_factor",
"defense_factor", "speed", "max_level"]

var stats_to_display: CharacterStats
@export var packed_stat_row: PackedScene

@onready var name_label: Label = $Top/Label
func _ready():
	name_label.text = stats_to_display.character_name
	for stat in DISPLAYED_STATS:
		var stat_row := packed_stat_row.instantiate()
		stat_row.left_text = tr(stat_starfix + stat.capitalize())
		stat_row.right_text = str(stats_to_display[stat])
		add_child(stat_row)
	
