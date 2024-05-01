extends CanvasLayer

const InputLine = preload("res://lib/ui/settings/components/stin_input_keybind.tscn")
var input_data = [
	{"id": "move_forward", "name": "Move Forward" },
	{"id": "move_back", "name": "Move Back" },
	{"id": "strafe_left", "name": "Strafe Left" },
	{"id": "strafe_right", "name": "Strafe Right" },
	{"id": "interact", "name": "Interact" },
	{"id": "zoom_in", "name": "Zoom In" },
	{"id": "zoom_out", "name": "Zoom Out" } ]

var input_containers = [] # input list nodes, so they can be cleared on refresh

func _get_key(input_id):
	var action = InputMap.action_get_events(input_id)[0]
	if str(action).split(" ")[1] == "button_index=4,":
		return("Scroll Up")
	elif str(action).split(" ")[1] == "button_index=5,":
		return("Scroll Down")
	else: return(str(action).split(" ")[2].lstrip("(").rstrip("),"))

# Move the "reset" button to the bottom of the menu after reloading the menu
func _reset_to_bottom():
	$Control/Panel/VBox.move_child($Control/Panel/VBox/ResetButton, -1)
	$Control/Panel/VBox.move_child($Control/Panel/VBox/LowerCloseButton, -1)

func open(): visible = true
func close(): visible = false

func apply_input_data():
	for i in input_data:
		InputMap.action_erase_events(i.id)
		if i.type == "key":
			var e = InputEventKey.new()
			e.physical_keycode = i.code
			InputMap.action_add_event(i.id, e)
		elif i.type == "mouse":
			var e = InputEventMouseButton.new()
			e.button_index = i.code
			InputMap.action_add_event(i.id, e)

func refresh_input_data():
	for node in input_containers: node.queue_free()
	input_containers = []
	save_input_data()
	
	# Update input map display
	for input in input_data:
		var i = InputLine.instantiate()
		i.populate(input.name, input.id, _get_key(input.id))
		input_containers.append(i)
		$Control/Panel/VBox.add_child(i)
	
	_reset_to_bottom()
	# To avoid instantly triggering that input just by setting it
	# TODO: fix; this isn't that ideal...
	await get_tree().create_timer(0.2).timeout
	Global.in_keybind_select = false

func expand_input_data():
	for input in input_data:
		var event = InputMap.action_get_events(input.id)[0]
		if event is InputEventMouseButton:
			input["type"] = "mouse"
			input["code"] = event.button_index
		elif event is InputEventKey:
			input["type"] = "key"
			input["code"] = event.physical_keycode

func save_input_data(): # save input data to "input_data.json" file
	expand_input_data()
	var inputs_json = FileAccess.open("user://input_data.json", FileAccess.WRITE)
	inputs_json.store_string(JSON.stringify(input_data))
	inputs_json.close()

func _ready():
	expand_input_data()

	# Only do this once (from the loading screen)
	if Global.input_data_loaded == false:
		Global.original_input_data = input_data.duplicate()
		if FileAccess.file_exists("user://input_data.json"):
			var inputs_file = FileAccess.open("user://input_data.json", FileAccess.READ)
			var inputs_json = JSON.parse_string(inputs_file.get_as_text())
			
			# TODO: better checking for input data validity
			print("[InputSettings] valid input_data.json exists, loading.")
			input_data = inputs_json
			inputs_file.close()
		else:
			print("[InputSettings] input_data.json doesn't exist, creating it.")
			save_input_data()
		Global.input_data_loaded = true
	
	apply_input_data()
	Global.connect("left_keybind_select", refresh_input_data)
	refresh_input_data()

func _input(_event):
	# Right click to close settings menu
	if Input.is_action_just_pressed("right_click"):
		if visible == true: close()

func _on_button_pressed():
	input_data = Global.original_input_data.duplicate()
	apply_input_data()
	refresh_input_data()
	Global.settings = Global.SETTINGS.duplicate()
	for setting in Global.settings:
		Global.setting_changed.emit(setting)

func _mouseover():
	Global.button_hover.emit()

func _on_control_mouse_entered(): Global.mouse_in_settings_menu = true
func _on_control_mouse_exited(): Global.mouse_in_settings_menu = false
