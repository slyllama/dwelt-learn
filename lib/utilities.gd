extends Node

# Get the shortest angle between "from", and "to", even if one or both exceeds 360deg
func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

# Return a float "num" as a string to 2 decimal places, or snapped to "place"
func fstr(num, place = 0.01):
	return(str(snapped(num, place)))

# Return string as centered BBCode text
func cntr(get_text: String):
	return("[center]" + get_text + "[/center]")

# SETTINGS LOADING AND SAVING

signal settings_loaded

func save_settings(): # save settings to "settings.json" file
	var settings_json = FileAccess.open("user://settings.json", FileAccess.WRITE)
	settings_json.store_string(JSON.stringify(Global.settings))
	settings_json.close()

func load_settings():
	# Load the settings file, or make a new one using save_settings() if it doesn't
	if FileAccess.file_exists("user://settings.json"):
		var settings_json = FileAccess.open("user://settings.json", FileAccess.READ)
		Global.settings = JSON.parse_string(settings_json.get_as_text())
		print("[Settings] settings.json exists, loading.")
		for setting in Global.SETTINGS:
			if !setting in Global.settings:
				Global.settings[setting] = Global.SETTINGS[setting]
				print("[Settings] Missing setting '" + setting + "' in settings.json, adding it.")
		settings_json.close()
	else:
		print("[Settings] settings.json doesn't exist, creating it.")
		save_settings()
		Global.settings = Global.SETTINGS
	settings_loaded.emit()
