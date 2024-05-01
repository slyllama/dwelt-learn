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
		"volume":
			# Don't apply volume on first run, because we are fading it in below
			if first_settings_run == true: Utilities.set_master_vol(Global.settings.volume)
		"spot_shadows":
			for child in Utilities.get_all_children(get_tree().root):
				if child in exclude_from_shadow: return
				if child is SpotLight3D or child is OmniLight3D:
					child.shadow_enabled = Global.settings.spot_shadows
		"vol_fog": $Sky.get_environment().volumetric_fog_enabled = Global.settings.vol_fog
		"full_screen":
			if first_settings_run == true: Utilities.toggle_full_screen()
	Utilities.save_settings()

func _ready():
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings: Global.setting_changed.emit(setting)
	$HUD/Settings/Control/Panel/VBox/LargerUI.visible = false
	
	# Fade in all sound if the game wasn't already muted
	Utilities.set_master_vol(0.0)
	var fade_bus_in = create_tween()
	fade_bus_in.tween_method(Utilities.set_master_vol, 0.0, Global.settings.volume, 1.5)
