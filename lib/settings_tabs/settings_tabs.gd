extends CanvasLayer

var is_open = false
signal closed

func open():
	$Container.current_tab = 0
	$Container.get_child(0, true).grab_focus()
	
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
	visible = false
	$Container.set_tab_title(0, "GENERAL")
	$Container.set_tab_title(1, "INPUT")
	$Container.set_tab_title(2, "CONTROLLER")

func _input(event):
	if Utilities.is_joy_button(event, JOY_BUTTON_START):
		if visible == false: open()
		else: close()
	if Input.is_action_just_pressed("ui_cancel"):
		if visible == true: close()
