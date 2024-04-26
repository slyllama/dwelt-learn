extends CanvasLayer

@export var fps_lower_limit = 20

func _fov_changed(_release):
	$Settings/FOVSlider.value = Global.settings.fov
	$Settings/FOVText.text = "FOV: " + str(Global.settings.fov) + "\u00B0"

func _camera_sens_changed(_release):
	$Settings/CameraSens.value = Global.settings.camera_sens
	$Settings/CameraSensText.text = ("Camera Sensitivity: "
		+ str(snapped($Settings/CameraSens.value / $Settings/CameraSens.max_value * 100, 1)) + "%")

func _mute_changed():
	$Settings/MuteButton.button_pressed = Global.settings.mute

func _blend_shadow_splits():
	$Settings/BlendShadowButton.button_pressed = Global.settings.blend_shadow_splits

func _ready():
	visible = false
	
	# Apply settings and connect global changes
	Global.connect("fov_changed", _fov_changed)
	Global.emit_signal("fov_changed", false)
	Global.connect("mute_changed", _mute_changed)
	Global.emit_signal("mute_changed")
	Global.connect("blend_shadow_splits_changed", _blend_shadow_splits)
	Global.emit_signal("blend_shadow_splits_changed")
	Global.connect("camera_sens_changed", _camera_sens_changed)
	Global.emit_signal("camera_sens_changed", false)

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug"): visible = !visible

func _process(_delta):
	var colour = "green"
	$Details.text = str(Global.debug_details_text)
	var fps = Engine.get_frames_per_second()
	if fps < fps_lower_limit:
		colour = "red"
	$FPSCounter.text = ("[color=" + colour + "]"
		+ str(Engine.get_frames_per_second()) + "fps[/color]")

func _on_fov_slider_value_changed(value):
	Global.settings.fov = $Settings/FOVSlider.value
	Global.emit_signal("fov_changed", false)
func _on_fov_slider_drag_started(): Global.dragging_control = true
func _on_fov_slider_drag_ended(_value_changed):
	Global.dragging_control = false
	Global.emit_signal("fov_changed", true)

func _on_camera_sens_value_changed(value):
	Global.settings.camera_sens = $Settings/CameraSens.value
	Global.emit_signal("camera_sens_changed", false)
func _on_camera_sens_drag_started(): Global.dragging_control = true
func _on_camera_sens_drag_ended(_value_changed):
	Global.dragging_control = false
	Global.emit_signal("camera_sens_changed", true)

func _on_mute_button_pressed():
	Global.settings.mute = !Global.settings.mute
	Global.emit_signal("mute_changed")

func _on_blend_shadow_button_pressed():
	Global.settings.blend_shadow_splits = !Global.settings.blend_shadow_splits
	Global.emit_signal("blend_shadow_splits_changed")

func _on_reset_pressed():
	Global.settings = Global.SETTINGS
	Global.emit_signal("fov_changed", false)
	Global.emit_signal("mute_changed")
	Global.emit_signal("blend_shadow_splits_changed")
	Global.emit_signal("camera_sens_changed", false)
