extends Node

var previous_title := ""
var previous_stopping := true
var requests: Array[TextModalRequest] = []
@export var text_modal : PackedScene

# This is meant to load in stuff with near-natural stageplay script writing, ala renpy
# func parse_chat_script(s: String):
#     pass


# func _process(_delta: float) -> void:
#     pass


func create_modal(req: TextModalRequest) -> TextModal:
	var o : TextModal = text_modal.instantiate()
	if not o:
		assert(false, "Failed to instantiate text modal '{0}' at '{1}'.".format([text_modal, text_modal.resource_path]))
		return null
	o.title = req.title
	o.content = req.content
	o.position = req.placement
	o.is_stopping = req.is_stopping
	if req.add_as_child_of:
		req.add_as_child_of.add_child(o)
	else:
		add_child(o)
	return o

func run_request_queue():
	return create_modal(requests.pop_front())
