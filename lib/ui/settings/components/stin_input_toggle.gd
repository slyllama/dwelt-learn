@tool
extends HBoxContainer

@export var setting_id: String
@export var setting_title = "[Setting]"

func _ready():
	$Title.text = str(setting_title)
	
	if Engine.is_editor_hint() == true: return
	if !setting_id in Global.settings:
		Global.printc("[Settings] tried to load setting '" + str(setting_id) +"' but it doesn't exist.")
		queue_free()
		return
	
	$Toggle.button_pressed = Global.settings[setting_id]
	Global.setting_changed.connect(func(get_setting_id):
		if get_setting_id == setting_id and setting_id != null:
			$Toggle.button_pressed = Global.settings[setting_id])

func _on_toggle_pressed():
	Global.settings[setting_id] = !Global.settings[setting_id]
	Global.setting_changed.emit(setting_id)

func _on_toggle_mouse_entered(): Global.button_hover.emit()
func _on_toggle_focus_entered(): Global.button_hover.emit()
