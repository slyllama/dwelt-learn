extends CanvasLayer

func _toggle_settings():
	if $Settings.visible == false:
		$Settings.open()
	else: $Settings.close()

func _toggle_interact_overlay(state):
	if state == true:
		var fade_tween = create_tween()
		fade_tween.tween_property(
			$InteractOverlay, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	else:
		var fade_tween = create_tween()
		fade_tween.tween_property(
			$InteractOverlay, "modulate", Color(0.0, 0.0, 0.0, 0.2), 0.2)

func _fade_out_black():
	var fade_tween = create_tween()
	fade_tween.tween_property($LoadOverride/LoadBlack, "modulate:a", 0.0, 0.2)
	fade_tween.tween_callback(func():
		$LoadOverride/LoadBlack.visible = false
		$SmokeOverlay.deactivate())

func _ready():
	Global.shaders_loaded.connect(_fade_out_black)
	Action.targeted.connect(_toggle_interact_overlay.bind(true))
	Action.untargeted.connect(_toggle_interact_overlay.bind(false))
	
	$SmokeOverlay/BG.visible = true
	$InteractOverlay.modulate = Color(0.0, 0.0, 0.0, 0.2)
	$LoadOverride/LoadBlack.visible = true
	$HUDButtons.settings_pressed.connect(_toggle_settings)

func _mouseover():
	Global.button_hover.emit()
