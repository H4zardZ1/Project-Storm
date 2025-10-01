extends Control

# Emitted when an Action is dropped into this node.
signal targetted_drop(by)
# const THRESHOLD_RED = 0.1
# const THRESHOLD_YELLOW = 0.25
var combatant : FightCombatant
const ROTATE_THRESHOLD_LUNE = 36.0 / 360.0

@export var hp_node: Range
@export var hp_text: RichTextLabel
@export var level_node: Range
@export var level_text: RichTextLabel
@export var emo_node: Range
@export var emo_text: RichTextLabel
# @export var mental_node: Range
# the odd one out
@export var mental_node: DirectionalLight3D
@export var mental_text: RichTextLabel
@export var pp_node: Range
@export var pp_text: RichTextLabel
@export var combatant_label: RichTextLabel

func update_visual() -> void:
	if is_instance_valid(hp_node):
		hp_node.max_value = combatant.max_health
		hp_node.value = combatant.health
	if is_instance_valid(hp_text):
		hp_text.text = ""
		# var a: float = combatant.health
		# var b: float = combatant.max_health
		# if (a / b) <= THRESHOLD_RED:
		#     hp_text.push_color(Color.RED)
		# elif (a / b) <= THRESHOLD_YELLOW:
		#     hp_text.push_color(Color.YELLOW)
		# elif a < b:
		#     hp_text.push_color(Color.GREEN)
		# else:
		#     hp_text.push_color(Color.WHITE)
		hp_text.append_text("{v}/{max}".format({
			"v": combatant.health, 
			"max": combatant.max_health
		}))
		#hp_text.popall()
	if is_instance_valid(level_node):
		level_node.max_value = combatant.max_level
		level_node.value = combatant.level
	if is_instance_valid(level_text):
		level_text.text = ""
		# var a: float = combatant.health
		# var b: float = combatant.max_health
		# if (a / b) <= THRESHOLD_RED:
		#     hp_text.push_color(Color.RED)
		# elif (a / b) <= THRESHOLD_YELLOW:
		#     hp_text.push_color(Color.YELLOW)
		# elif a < b:
		#     hp_text.push_color(Color.GREEN)
		# else:
		#     hp_text.push_color(Color.WHITE)
		level_text.append_text("{v}/{max}".format({
			"v": combatant.level, 
			"max": combatant.max_level
		}))
	
	# mental gauge is a special case here
	# the normal case is commented below
	if is_instance_valid(mental_node):
		mental_node.transform.basis = Basis.IDENTITY
		mental_node.rotate_x(TAU * remap(combatant.mental, 0, combatant.max_mental, ROTATE_THRESHOLD_LUNE, 0.5 - ROTATE_THRESHOLD_LUNE))
	# if is_instance_valid(mental_node):
	#     mental_node.max_value = combatant.max_mental
	#     mental_node.value = combatant.mental
	if is_instance_valid(mental_text):
		mental_text.text = ""
		# var a: float = combatant.mental
		# var b: float = combatant.max_mental
		# if (a / b) <= THRESHOLD_RED:
		#     mental_text.push_color(Color.RED)
		# elif (a / b) <= THRESHOLD_YELLOW:
		#     mental_text.push_color(Color.YELLOW)
		# elif a < b:
		#     mental_text.push_color(Color.GREEN)
		# else:
		#     mental_text.push_color(Color.WHITE)
		mental_text.append_text("{v}/{max}".format({
			"v": combatant.mental, 
			"max": combatant.max_mental
		}))
		#mental_text.popall()
	if is_instance_valid(pp_node):
		pp_node.max_value = combatant.current_max_play_points
		pp_node.value = combatant.play_points
	if is_instance_valid(pp_text):
		pp_text.text = ""
		# var a: float = combatant.health
		# var b: float = combatant.max_health
		# if (a / b) <= THRESHOLD_RED:
		#     pp_text.push_color(Color.RED)
		# elif (a / b) <= THRESHOLD_YELLOW:
		#     pp_text.push_color(Color.YELLOW)
		# elif a < b:
		#     pp_text.push_color(Color.GREEN)
		# else:
		#     pp_text.push_color(Color.WHITE)
		pp_text.append_text("{v}/{max}".format({
			"v": combatant.play_points, 
			"max": combatant.current_max_play_points
		}))
		#pp_text.popall()
	if is_instance_valid(emo_node):
		emo_node.max_value = combatant.current_emotion_limit
		emo_node.value = combatant.emo
	if is_instance_valid(emo_text):
		emo_text.text = ""
		emo_text.append_text("{v}/{max}".format({
			"v": combatant.emo, 
			"max": combatant.current_emotion_limit
		}))
	if is_instance_valid(combatant_label):
		combatant_label.text = combatant.combatant_name


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# go back to this 
	var result := data is Action
	
	return result

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is Action:
		targetted_drop.emit(data)
	
