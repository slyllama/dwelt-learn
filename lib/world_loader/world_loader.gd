extends Node3D

func get_all_children(in_node, arr := []):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return(arr)

# This script loads settings, music, and other things into the world.
# It should be extended after creating a new scene. NOTE: 'initialise()' MUST
# called in order for everything to be loaded properly.

func _setting_changed(get_setting_id):
	match get_setting_id:
		"fov": %Player/CamPivot/CamArm/Camera.fov = Global.settings.fov
		"camera_sens": %Player/CamPivot.camera_sensitivity = Global.settings.camera_sens
		"volume": AudioServer.set_bus_volume_db(0, linear_to_db(Global.settings.volume))
		"spot_shadows":
			for child in get_all_children(get_tree().root):
				if child is SpotLight3D or child is OmniLight3D:
					child.shadow_enabled = Global.settings.spot_shadows
		"vol_fog": $Sky.get_environment().volumetric_fog_enabled = Global.settings.vol_fog
	Utilities.save_settings()

func _settings_loaded():
	# Apply settings and connect global changes
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings:
		Global.setting_changed.emit(setting)

func set_master_vol(vol):
	AudioServer.set_bus_volume_db(0, vol)

func _init():
	RenderingServer.set_debug_generate_wireframes(true)

func _ready():
	Utilities.settings_loaded.connect(_settings_loaded)
	Utilities.load_settings()
	
	# Fade in all sound if the game wasn't already muted
	set_master_vol(linear_to_db(Global.settings.volume / 2.0))
	var fade_bus_in = create_tween()
	# Divide global volume by two to get lower volume, to avoid sound playing
	# when the game was muted
	fade_bus_in.tween_method(
		set_master_vol,
		linear_to_db(Global.settings.volume / 2.0),
		linear_to_db(Global.settings.volume), 1.0
	).set_trans(Tween.TRANS_EXPO)
	
	# Only try to prime music if the nodes actually exist
	if get_node_or_null("Ambience") != null and get_node_or_null("Music") != null:
		$Ambience.volume_db = -20.0
		var ambi_tween = create_tween()
		ambi_tween.tween_property($Ambience, "volume_db", -3.0, 2.0).set_trans(Tween.TRANS_EXPO)
		await get_tree().create_timer(4.0).timeout
		$Music.play()
	else:
		print("Missing music nodes!")

var debug_draw = false

func _input(_event):
	if Input.is_action_just_pressed("test_key"):
		if debug_draw == false: get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		else: get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		debug_draw = !debug_draw
