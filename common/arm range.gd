@tool
extends Range
class_name Gauge
## A control that uses an arm Texture2D to represent a percentage.
##
## A control that uses an arm Texture2D to represent a percentage. 


## Emitted when either [member max_angle], [member min_angle], [member arm_base_offset] or [member arm_center] change.
signal visual_constraints_changed()
## The maximum angle in degrees that the node allows.
## If [member Range.allow_greater] is true, this is when [member Range.value] is equal to it.
@export var max_angle: float = 360.0 :
	get:
		return max_angle
	set(n):
		if n != max_angle:
			visual_constraints_changed.emit()
		max_angle = n
		update_configuration_warnings()
		
## The minimum angle in degrees that the node allows.
## If [member Range.allow_lesser] is true, this is when [member Range.value] is equal to it.
@export var min_angle: float = 0.0:
	get:
		return min_angle
	set(n):
		if n != min_angle:
			visual_constraints_changed.emit()
		min_angle = n
		update_configuration_warnings()

## The arm of the gauge. Rotates with [member Range.value].
@export var arm_texture: Texture2D = null:
	get:
		return arm_texture
	set(o):
		if is_instance_valid(arm_texture) and arm_texture.changed.is_connected(queue_redraw):
			arm_texture.changed.disconnect(queue_redraw)
		if is_instance_valid(o):
			o.changed.connect(queue_redraw)
		arm_texture = o
		queue_redraw()
## The center of the arm texture, for the pivot of the rotation of the arm itself.
@export var arm_center: Vector2:
	get:
		return arm_center
	set(vec):
		if vec != arm_center:
			visual_constraints_changed.emit()
		arm_center = vec

## The offset of the arm center from the center of this node.
@export var arm_base_offset: Vector2 = Vector2.ZERO:
	get:
		return arm_base_offset
	set(vec):
		if vec != arm_base_offset:
			visual_constraints_changed.emit()
		arm_base_offset = vec

var center: Vector2:
	get:
		return size / 2.0

func _init() -> void:
	changed.connect(queue_redraw)
	value_changed.connect(queue_redraw)
	visual_constraints_changed.connect(queue_redraw)

func _draw() -> void:
	if not is_equal_approx(max_angle, min_angle):
		# lerp_angle wants to lerp through the shortest angle.
		# not what we want, we want to rotate the long way
		draw_set_transform(center + arm_base_offset, remap(value, min_value, max_value, min_angle, max_angle) * TAU / 360)
	else:
		draw_set_transform(center + arm_base_offset, max_angle)
	draw_texture(arm_texture, -arm_center)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray
	if is_equal_approx(max_angle, min_angle):
		warnings.append("max_angle and min_angle are too close to each other.")
	if not is_instance_valid(arm_texture):
		warnings.append("Missing arm_texture to draw.")
	return warnings
