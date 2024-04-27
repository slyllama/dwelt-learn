extends CanvasLayer

const InputLine = preload("res://lib/ui/settings/stin_input_keybind.tscn")
var original_input_data = []
var input_data = [
	{"id": "move_forward", "name": "Move Forward" },
	{"id": "move_back", "name": "Move Back" },
	{"id": "strafe_left", "name": "Strafe Left" },
	{"id": "strafe_right", "name": "Strafe Right" },
	{"id": "interact", "name": "Interact" },
	{"id": "zoom_in", "name": "Zoom In" },
	{"id": "zoom_out", "name": "Zoom Out" },
	{"id": "toggle_debug", "name": "Toggle Debug" } ]

var input_containers = [] # input list nodes, so they can be cleared on refresh

func _get_key(input_id):
	var action = InputMap.action_get_events(input_id)[0]
	if str(action).split(" ")[1] == "button_index=4,":
		return("Scroll Up")
	elif str(action).split(" ")[1] == "button_index=5,":
		return("Scroll Down")
	else: return(str(action).split(" ")[2].lstrip("(").rstrip("),"))

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

func save_input_data(): # save input data to "inputs.json" file
	expand_input_data()
	var inputs_json = FileAccess.open("user://input_data.json", FileAccess.WRITE)
	inputs_json.store_string(JSON.stringify(input_data))
	inputs_json.close()

func _ready():
	expand_input_data()
	original_input_data = input_data.duplicate()
	
	if FileAccess.file_exists("user://input_data.json"):
		var inputs_json = FileAccess.open("user://input_data.json", FileAccess.READ)
		print("[InputSettings] 'inputs.json' exists, loading.")
		input_data = JSON.parse_string(inputs_json.get_as_text())
		inputs_json.close()
	else:
		print("[InputSettings] 'inputs.json' doesn't exist, creating it.")
		save_input_data()
	
	apply_input_data()
	Global.connect("left_keybind_select", refresh_input_data)
	refresh_input_data()

func _on_button_pressed():
	input_data = original_input_data.duplicate()
	apply_input_data()
	refresh_input_data()
	Global.settings = Global.SETTINGS.duplicate()
	for setting in Global.settings:
		Global.setting_changed.emit(setting)

func _mouseover():
	Global.button_hover.emit()
