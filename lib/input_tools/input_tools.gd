extends Node
# input_tools.gd
# A small handler that should be somewhere in every scene. It ensures that
# handoffs between the keyboard and controller are handled properly.

# Switch to controller if one is found - only do this on first run
func check_for_controller():
	if Input.get_connected_joypads().size() > 0:
		Global.input_mode = Global.InputModes.CONTROLLER
		Global.printc("[InputTools] controller selected as input.")
	else: Global.printc("[InputTools] keyboard selected as input.")
	Global.input_mode_switched.emit()

func _input(event):
	if event is InputEventKey:
		if Global.input_mode == Global.InputModes.CONTROLLER:
			Global.input_mode = Global.InputModes.KEYBOARD
			Global.printc("[InputTools] keyboard selected as input.")
			Global.input_mode_switched.emit()
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if Global.input_mode == Global.InputModes.KEYBOARD:
			Global.input_mode = Global.InputModes.CONTROLLER
			Global.printc("[InputTools] controller selected as input.")
			Global.input_mode_switched.emit()
