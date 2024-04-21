extends Control

const InputLine = preload("res://lib/ui/input_settings/input_line.tscn")
const INPUTS = [
	{"id": "move_forward", "name": "Move Forward" },
	{"id": "move_back", "name": "Move Back" },
	{"id": "strafe_left", "name": "Strafe Left" },
	{"id": "strafe_right", "name": "Strafe Right" },
	{"id": "interact", "name": "Interact" },
	{"id": "zoom_in", "name": "Zoom In" },
	{"id": "zoom_out", "name": "Zoom Out" } ]

var input_containers = [] # input list nodes, so they can be cleared

func _get_key(input_id):
	var action = InputMap.action_get_events(input_id)[0]
	
	if str(action).split(" ")[1] == "button_index=4,":
		return("Scroll Up")
	elif str(action).split(" ")[1] == "button_index=5,":
		return("Scroll Down")
	else:
		return(str(action).split(" ")[2].lstrip("(").rstrip("),"))

func refresh():
	for node in input_containers: node.queue_free()
	input_containers = []
	
	for input in INPUTS:
		var i = InputLine.instantiate()
		i.populate(input.name, input.id, _get_key(input.id))
		input_containers.append(i)
		$Panel/Scroll/VBox.add_child(i)
	$Panel/Scroll/VBox.move_child($Panel/Scroll/VBox/ResetContainer, -1)
	
	# To avoid instantly applying
	# TODO: this isn't that ideal...
	await get_tree().create_timer(0.2).timeout
	Global.in_keybind_select = false

func _ready():
	Global.connect("left_keybind_select", refresh)
	refresh()

func _on_reset_pressed():
	InputMap.load_from_project_settings()
	refresh()
