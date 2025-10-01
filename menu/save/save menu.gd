extends PanelContainer

@export var text_node: LineEdit
# no i have no clue what gbu means now
# its green it's probably time-related stuff
@export var save_button: BaseButton
@export var load_button: BaseButton
@export var save_enabled := true
@export var load_enabled := true


@export var save_table: PackedScene
func _ready() -> void:
	_after_ready.call_deferred()

		

func _after_ready() -> void:
	await get_tree().process_frame
	var werror := ""
	for dir in DirAccess.get_directories_at("user://player"):
		var file := FileAccess.open("user://player/{0}/player.dat".format([dir]), FileAccess.READ)
		if not is_instance_valid(file):
			var current_error: int = FileAccess.get_open_error()
			werror += "\n\terror '{0}' occured at '{1}'".format([
				error_string(current_error),
				dir
			])
			continue
		var o: Control = save_table.instantiate()
		if not o:
			assert(false, "Root node in {0} is not Control ".format([save_table.resource_path]))
			break
		var j: RichTextLabel = o.get_child(0, false)
		if not is_instance_valid(j):
			assert(false, "First child in {0} is not RichTextLabel ".format([save_table.resource_path]))
			break
		o.gui_input.connect(_handle_obj.bind(o, dir))
		var time_last_save := FileAccess.get_modified_time("user://player/{0}/player.dat".format([dir]))
		@warning_ignore_start("integer_division")
		j.append_text(tr("SAVEFILE_TIME_FORMAT").format(
			{
				"name": dir,
				"hour": time_last_save / 3600,
				"minute": var_to_str((time_last_save / 60) % 60).pad_zeros(2),
				"second": var_to_str((time_last_save) % 60).pad_zeros(2)
			}
		))
		@warning_ignore_restore("integer_division")
		j.newline()
		var d := Time.get_datetime_dict_from_unix_time(time_last_save)
		j.append_text("[color=green]{0}[/color]".format(
			tr("DATE_FORMAT").format({ 
				"year": d.year, 
				"month": d.month, 
				"day": d.day, 
				"hour": d.hour, 
				"minute": d.minute, 
				"second": d.second
			})
		))
	if werror:
			push_error("During loading savefiles (currently located at '{0}'), by '{1}', the following error(s) have occured:\n{2}".format(
				[
					ProjectSettings.globalize_path("user://player"),
					self,
					werror
				]
			))
			

func _save_enable_changed() -> void:
	save_button.visible = save_enabled

func _load_enable_changed() -> void:	
	load_button.visible = load_enabled


func _on_text_edit_text_set() -> void:
	save_button.disabled = not (text_node.text or save_enabled)
	load_button.disabled = not (text_node.text or load_enabled)

func save_data() -> void:
	PlayerData.save_name = text_node.text
	PlayerData.save_data()

func _handle_obj(input: InputEvent, o: Control, save_name: String) -> void:
	if o.has_focus() and input.is_action_pressed("ui_accept"):
		text_node.text = save_name

func save_data_name(save_name: String) -> void:
	PlayerData.save_name = save_name
	PlayerData.save_data()

func load_data() -> void:
	PlayerData.save_name = text_node.text
	PlayerData.load_data()
