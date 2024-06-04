extends CanvasLayer

var is_open = false
signal closed

func open():
	$Container/General/VBox/ReturnToMenu.grab_focus()
	is_open = true
	#$Container/General/VBox/ReturnToMenu.grab_focus()
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
	$Container.set_tab_title(0, "GENERAL")
	$Container.set_tab_title(1, "INPUT")
	$Container.set_tab_title(2, "CONTROLLER")
	open()

func _input(event):
	if Utilities.is_joy_button(event, JOY_BUTTON_START):
		if visible == false: open()
		else: close()
	if Input.is_action_just_pressed("ui_cancel"):
		if visible == true: close()

func _on_return_to_menu_pressed():
	close()
