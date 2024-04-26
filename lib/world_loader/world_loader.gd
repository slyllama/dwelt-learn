extends Node3D

# This script loads settings, music, and other things into the world.
# It should be extended after creating a new scene. NOTE: 'initialise()' MUST
# called in order for everything to be loaded properly.

func _setting_changed(get_setting_id):
	match get_setting_id:
		"mute": AudioServer.set_bus_mute(0, Global.settings.mute)
		"fov": %Player/CamPivot/CamArm/Camera.fov = Global.settings.fov
		"camera_sens": %Player/CamPivot.camera_sensitivity = Global.settings.camera_sens
	save_settings()

func save_settings(): # save settings to "settings.json" file
	var settings_json = FileAccess.open("user://settings.json", FileAccess.WRITE)
	settings_json.store_string(JSON.stringify(Global.settings))
	settings_json.close()

func set_master_vol(vol):
	AudioServer.set_bus_volume_db(0, vol)

func initialise():
	# Set up for retina
	if DisplayServer.screen_get_size().x > 2000:
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(load("res://generic/tex/cursor_2x.png"))
	
	# Load the settings file, or make a new one using save_settings() if it doesn't
	if FileAccess.file_exists("user://settings.json"):
		var settings_json = FileAccess.open("user://settings.json", FileAccess.READ)
		Global.settings = JSON.parse_string(settings_json.get_as_text())
		print("[Settings] 'settings.json' exists, loading.")
		settings_json.close()
	else:
		print("[Settings] 'settings.json' doesn't exist, creating it.")
		save_settings()
	
	# Apply settings and connect global changes
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings:
		Global.setting_changed.emit(setting)

	# Fade in all sound if the game wasn't already muted
	if Global.settings.mute == false:
		set_master_vol(-20.0)
		var fade_bus_in = create_tween()
		fade_bus_in.tween_method(set_master_vol, -20.0, 0.0, 1.0).set_trans(Tween.TRANS_EXPO)
	#
	# Only try to prime music if the nodes actually exist
	if get_node_or_null("Ambience") != null and get_node_or_null("Music") != null:
		$Ambience.volume_db = -20.0
		var ambi_tween = create_tween()
		ambi_tween.tween_property($Ambience, "volume_db", -3.0, 2.0).set_trans(Tween.TRANS_EXPO)
		await get_tree().create_timer(4.0).timeout
		$Music.play()
	else:
		print("Missing music nodes!")
