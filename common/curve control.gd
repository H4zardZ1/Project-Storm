extends Control
class_name CurveControl

var ejection_dir := Transform2D((3 * TAU) / 16, Vector2.ZERO)
var line_width: float = -1.0
var color: Color

var connected_item: CanvasItem:
	set(value):
		if is_instance_valid(connected_item):
			if connected_item.item_rect_changed.is_connected(queue_redraw):
				connected_item.item_rect_changed.disconnect(queue_redraw)
		if is_instance_valid(value):
			if not value.item_rect_changed.is_connected(queue_redraw):
				value.item_rect_changed.connect(queue_redraw)
		connected_item = value
	get:
		return connected_item

func _init():
	set_notify_transform(true)

func _draw():
	var curve := Curve2D.new()
	var destination_point: Vector2

	print(connected_item.get_global_transform().origin)
	destination_point = (connected_item.get_global_transform().origin - global_position)
	var control_point := destination_point * ejection_dir

	curve.add_point(Vector2.ZERO, Vector2.ZERO, control_point / 2)
	curve.add_point(destination_point, (control_point - destination_point) / 2)
	
	draw_polyline(curve.tessellate(), color, line_width)

func _notification(what: int):
	if what == NOTIFICATION_PARENTED:
		if get_parent() is CanvasItem:
			connected_item = (get_parent() as CanvasItem)
	elif what == NOTIFICATION_UNPARENTED:
		connected_item = null
	elif what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()
