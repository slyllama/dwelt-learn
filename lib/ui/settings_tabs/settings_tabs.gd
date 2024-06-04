extends CanvasLayer

var is_open = false
signal closed

func open():
	is_open = true
	$Container/General/VBox/ReturnToMenu.grab_focus()
	visible = true
	Global.settings_opened = true

func _ready():
	$Container.set_tab_title(0, "GENERAL")
	$Container.set_tab_title(1, "INPUT")
	$Container.set_tab_title(2, "CONTROLLER")
	
	open()
