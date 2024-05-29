extends Node

var input_data = [
	{"id": "move_forward", "name": "FORWARD" },
	{"id": "move_back", "name": "BACK" },
	{"id": "strafe_left", "name": "STRAFE LEFT" },
	{"id": "strafe_right", "name": "STRAFE RIGHT" },
	{"id": "interact", "name": "INTERACT" },
	{"id": "skill_glide", "name": "GLIDE" },
	{"id": "skill_ping", "name": "PING" },
	{"id": "zoom_in", "name": "ZOOM IN" },
	{"id": "zoom_out", "name": "ZOOM OUT" } ]

### ENGINE/GAME SCRIPTS

func is_joy_button(event, button, state = "pressed") -> bool:
	if event is InputEventJoypadButton:
		if event.button_index == button:
			if state == "pressed" and event.pressed: return(true)
			if state == "released" and event.released: return(true)
		return(false)
	return(false)

# Set the master volume on a scale from 0.0 (muted) to 1.0 (1dB)
func set_master_vol(vol):
	AudioServer.set_bus_volume_db(0, linear_to_db(vol))

# Return an array of all children in the specified node
func get_all_children(in_node, arr := []):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return(arr)

# Checking for retina, and things like that
func configure_screen():
	if DisplayServer.screen_get_size().x > 2000:
		DisplayServer.window_set_min_size(Global.MIN_SCREEN_SIZE * 2.0)
		get_window().content_scale_factor = 2.0
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(
				load("res://lib/ui/tex/cursor_2x.png"))
	else: DisplayServer.window_set_min_size(Global.MIN_SCREEN_SIZE)

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
	return(Global.SCREEN_SIZE / 2.0)

# Perform checks to see if a node is actually interactable; used for ping
# skills and stuff like that
func get_is_valid_interactable(node, distance_to_player = 0.0):
	# if `distance_to_player` is 0.0, this check won't happen
	if distance_to_player > 0.0:
		var dist = Vector3(Global.player_position).distance_to(node.global_position)
		if dist > distance_to_player: return(false)
	
	if !node.get_parent().visible: return(false)
	if "interactable" in node:
		if !node.interactable: return(false)
	return(true)

# Get the name of an input command as a string
func get_key(input_id) -> String:
	if InputMap.action_get_events(input_id) == []: return("[!]")
	var action = InputMap.action_get_events(input_id)[0]
	if str(action).split(" ")[1] == "button_index=4,":
		return("SCROLL UP")
	elif str(action).split(" ")[1] == "button_index=5,":
		return("SCROLL DOWN")
	else: return(str(action).split(" ")[2].lstrip("(").rstrip("),"))

### CONSTRUCTION SCRIPTS

# Get the shortest angle between "from", and "to", even if one or both exceeds 360deg
func short_angle_dist(from, to) -> float:
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

# Return a float "num" as a string to 2 decimal places, or snapped to "place"
func fstr(num, place = 0.01) -> String:
	return(str(snapped(num, place)))

# Return a vector "vec" as a string to 2 decimal places, or snapped to "place"
func vecstr(vec, place = 0.01) -> String:
	return("("
		+ str(snapped(vec.x, place)) + ", "
		+ str(snapped(vec.y, place)) + ", "
		+ str(snapped(vec.z, place)) + ")")

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
		Global.printc("[Settings] settings.json exists, loading.")
		for setting in Global.SETTINGS:
			if !setting in Global.settings:
				Global.settings[setting] = Global.SETTINGS[setting]
				Global.printc("[Settings] Missing setting '" + setting + "' in settings.json, adding it.")
		settings_json.close()
	else:
		Global.printc("[Settings] settings.json doesn't exist, creating it.")
		save_settings()
		Global.settings = Global.SETTINGS
	settings_loaded.emit()
