class_name ClickyButton extends Button

## Enable this option to prevent the button from playing a sound the first time
## it is focused on.
@export var override_once = false
var overridden = false

func _ready():
	#mouse_entered.connect(func():
		#if !is_visible_in_tree(): return
		#Global.button_hover.emit())
	focus_entered.connect(func():
		if !is_visible_in_tree(): return
		if override_once == true:
			if overridden == false:
				overridden = true
				return
		Global.button_hover.emit())
