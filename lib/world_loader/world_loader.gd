extends Node3D

# All lights in here will be excluded from spotlight shadows. Remember to add
# to this before calling super().
var exclude_from_shadow = []
var first_settings_run = false

# This script loads settings, music, and other things into the world.
# It should be extended after creating a new scene. NOTE: 'super()' MUST
# called from the inheriting script in order for everything to be loaded
# properly.

func _setting_changed(get_setting_id):
	if first_settings_run == false: first_settings_run = true
	match get_setting_id:
		"fov": %Player/CamPivot/CamArm/Camera.fov = Global.settings.fov
		"camera_sens": %Player/CamPivot.camera_sensitivity = Global.settings.camera_sens
		"spot_shadows":
			for child in Utilities.get_all_children(get_tree().root):
				if child in exclude_from_shadow: return
				if child is SpotLight3D or child is OmniLight3D:
					child.shadow_enabled = Global.settings.spot_shadows
		"vol_fog":
			if get_node_or_null("Sky") == null: return
			$Sky.get_environment().volumetric_fog_enabled = Global.settings.vol_fog
	
	# The following are only applied after the first run
	if first_settings_run == true:
		match get_setting_id:
			"full_screen": Utilities.toggle_full_screen()
			"volume": Utilities.set_master_vol(Global.settings.volume)
			"larger_ui":
				if Global.settings.larger_ui == true: get_window().content_scale_factor = 1.3
				else: get_window().content_scale_factor = 1.0
	Utilities.save_settings()

func _ready():
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings: Global.setting_changed.emit(setting)
	
	# Fade in all sound if the game wasn't already muted
	Utilities.set_master_vol(0.0)
	await get_tree().create_timer(1.0).timeout
	var fade_bus_in = create_tween()
	fade_bus_in.tween_method(Utilities.set_master_vol, 0.0, Global.settings.volume, 1.5)
	if get_node_or_null("Music"): get_node("Music").play()
