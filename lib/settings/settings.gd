extends CanvasLayer

var is_open = false
signal closed

var can_tab = true # can use the arrow keys to swap tabs? (i.e., not on sliders)

func open():
	$Container.current_tab = 0
	$Container/SettingsGeneral/VBox/Done.grab_focus()
	
	is_open = true
	visible = true
	Global.settings_opened = true

func close():
	Global.button_click.emit()
	is_open = false
	visible = false
	closed.emit()
	# Prevent simultaneous action in the world (controller)!
	await get_tree().create_timer(0.2).timeout
	if !is_open: Global.settings_opened = false

func _ready():
	# Can't tab when using a slider
	get_viewport().gui_focus_changed.connect(func(node):
		if is_open: can_tab = !node is HSlider)
	
	visible = false
	$Container.set_tab_title(0, "GENERAL")
	$Container.set_tab_title(1, "INPUT")

func _input(event):
	if Input.is_action_just_pressed("ui_right") and can_tab:
		$Container.select_next_available()
		$Container.get_child(0, true).grab_focus()
	if Input.is_action_just_pressed("ui_left") and can_tab:
		$Container.select_previous_available()
		$Container.get_child(0, true).grab_focus()
	
	if (Utilities.is_joy_button(event, JOY_BUTTON_START)
		or Input.is_action_just_pressed("ui_cancel")):
		if !is_open:
			open()
			return
		else: close()

func _on_control_mouse_entered(): Global.mouse_in_settings_menu = true
func _on_control_mouse_exited(): Global.mouse_in_settings_menu = false

func _on_container_tab_changed(tab):
	# This is the most painful thing I have ever written
	$Container.get_child(0, true).set_focus_neighbor(SIDE_TOP,
		$Container.get_child(0, true).get_path_to($Container.get_tab_control(tab).get_node("VBox/Done")))
	Global.button_click.emit()

func _on_proceed_pressed():
	$ControllerLayout.visible = false
	$Container.get_tab_control(1).get_node("VBox/Done").grab_focus() # input tab

func _on_settings_input_controller_diagram_opened():
	$ControllerLayout.visible = true
	$ControllerLayout/Proceed.grab_focus()
