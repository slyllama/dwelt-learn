extends Panel

@onready var root = get_parent().get_parent()

func _on_menu_pressed():
	Save.game_saved.emit()
	Global.settings_opened = false
	get_tree().change_scene_to_file("res://lib/loading/loading.tscn")

func _on_done_pressed(): root.close()

func _on_default_pressed():
	Global.settings = Global.SETTINGS.duplicate()
	for setting in Global.settings:
		Global.setting_changed.emit(setting)
