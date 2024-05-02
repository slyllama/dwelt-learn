extends Node

### ENGINE/GAME SCRIPTS

# Set the master volume on a scale from 0.0 (muted) to 1.0 (1dB)
func set_master_vol(vol):
	AudioServer.set_bus_volume_db(0, linear_to_db(vol))

# Return an array of all children in the specified node
func get_all_children(in_node, arr := []):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return(arr)

# Toggle full screen
func toggle_full_screen():
	if Global.settings.full_screen == true:
		if (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED
			or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if Global.settings.full_screen == false:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

# Get the center of the window, adjusted by the content scale factor
func get_screen_center():
	if Global.settings.larger_ui == true:
		return(Global.SCREEN_SIZE / Global.LARGE_UI_SCALE / 2.0)
	else: return(Global.SCREEN_SIZE / 2.0)

# Prevent issues when spamming the interact key, or trying to interact with a
# different object in range when already in an action
func leave_action():
	if Global.in_action == false: return
	await get_tree().create_timer(0.2).timeout
	Global.in_action = false
	Global.action_left.emit()

### CONSTRUCTION SCRIPTS

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

### SETTINGS LOADING AND SAVING

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
