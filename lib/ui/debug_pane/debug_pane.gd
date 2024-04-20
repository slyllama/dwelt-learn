extends CanvasLayer

@export var fps_lower_limit = 20

func _fov_changed():
	$Settings/FOVSlider.value = Global.fov
	$Settings/FOVText.text = "FOV: " + str(Global.fov) + "\u00B0"

func _mute_changed():
	$Settings/MuteButton.button_pressed = Global.mute

func _blend_shadow_splits():
	$Settings/BlendShadowButton.button_pressed = Global.blend_shadow_splits

func _ready():
	visible = false
	
	# Apply settings and connect global changes
	Global.connect("fov_changed", _fov_changed)
	Global.emit_signal("fov_changed")
	Global.connect("mute_changed", _mute_changed)
	Global.emit_signal("mute_changed")
	Global.connect("blend_shadow_splits_changed", _blend_shadow_splits)
	Global.emit_signal("blend_shadow_splits_changed")

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug"):
		if visible == false:
			Global.emit_signal("deco_triggered")
		visible = !visible

func _process(_delta):
	var colour = "green"
	$Details.text = str(Global.debug_details_text)
	
	var fps = Engine.get_frames_per_second()
	if fps < fps_lower_limit:
		colour = "red"
	$FPSCounter.text = ("[color=" + colour + "]"
		+ str(Engine.get_frames_per_second()) + "fps[/color]")

func _on_fov_slider_value_changed(value):
	Global.fov = $Settings/FOVSlider.value
	Global.emit_signal("fov_changed")

func _on_mute_button_pressed():
	Global.mute = !Global.mute
	Global.emit_signal("mute_changed")

func _on_blend_shadow_button_pressed():
	Global.blend_shadow_splits = !Global.blend_shadow_splits
	Global.emit_signal("blend_shadow_splits_changed")
