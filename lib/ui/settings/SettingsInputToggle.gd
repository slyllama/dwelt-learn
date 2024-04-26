extends HBoxContainer

@export var setting_id: String
@export var setting_title = "[Setting]"

func _ready():
	$Title.text = str(setting_title)
	$Toggle.button_pressed = Global.settings[setting_id]
	Global.setting_changed.connect(func(get_setting_id):
		if get_setting_id == setting_id and setting_id != null:
			Global.settings[setting_id] = !Global.settings[setting_id])

func _on_toggle_pressed():
	Global.setting_changed.emit(setting_id)
