extends HBoxContainer

var active = false
var action_name
var action_id
var key_id

func populate(get_action_name, get_action_id, get_key_id):
	action_name = get_action_name
	action_id = get_action_id
	key_id = get_key_id
	$Label.text = get_action_name
	$Button.text = get_key_id

func cancel():
	Global.in_keybind_select = false
	active = false
	$CancelButton.visible = false
	populate(action_name, action_id, key_id)

func _input(event):
	if active == true:
		# Keybind change happens here
		if Input.is_anything_pressed():
			if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
				or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)): return
			InputMap.action_erase_events(action_id)
			InputMap.action_add_event(action_id, event)
			Global.emit_signal("left_keybind_select")

func _on_button_pressed():
	if Global.in_keybind_select == true: return # keybind select is already active
	Global.in_keybind_select = true
	active = true
	
	$Button.text = "PRESS KEY"
	$CancelButton.visible = true

func _on_cancel_button_pressed():
	if active == false: return
	cancel()

func _mouseover():
	Global.button_hover.emit()
