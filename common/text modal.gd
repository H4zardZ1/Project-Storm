extends Control
class_name TextModal
## Windowless text modal.
##
## Windowless text modal.

@export var enter_duration := 1.0
@export var hover_in_duration := 1.8
@export var hover_out_duration := 0.8
@export var hover_depth := 0.2
@export var vanish_duration := 1.0
var is_stopping := true
var title := "":
	set(s):
		title = s
		_title_change.call_deferred()
var _internal_tween : Tween = null

var content := "":
	set(s):
		content = s
		_content_change.call_deferred()

@export var title_node : RichTextLabel = null
@export var content_node : RichTextLabel = null

func _content_change() -> void:
	content_node.text = ""
	content_node.append_text(content)

func _title_change() -> void:
	title_node.text = ""
	title_node.append_text(title)

func _unhandled_input(event: InputEvent) -> void:
	if (is_stopping) or event.is_action("clear_text_modals"):
		vanish()

func vanish() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, vanish_duration)
	tween.tween_callback(self.queue_free)

func hovered() -> void:
	_internal_tween = create_tween()
	_internal_tween.tween_property(self, "modulate", Color(1, 1, 1, hover_depth), hover_in_duration)

func hover_ended() -> void:
	if _internal_tween:
		_internal_tween.kill()
		_internal_tween = create_tween()
	_internal_tween.tween_property(self, "modulate", Color.WHITE, hover_out_duration / inverse_lerp(1, hover_depth, modulate.a))


func enter() -> void:
	visible = true
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, enter_duration)
