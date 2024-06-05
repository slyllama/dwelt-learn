extends CanvasLayer

func _toggle_settings():
	if !$Settings.is_open:
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
	await get_tree().create_timer(0.5).timeout
	var fade_tween = create_tween()
	$SmokeOverlay.set_alpha($SmokeOverlay.max_alpha)
	$SmokeOverlay/BG.visible = true
	fade_tween.tween_property($LoadOverride/LoadBlack, "modulate:a", 0.0, 0.2)
	fade_tween.tween_callback(func():
		$LoadOverride/LoadBlack.visible = false
		Global.smoke_faded.emit("out"))

func _ready():
	Global.shaders_loaded.connect(_fade_out_black)
	Action.targeted.connect(_toggle_interact_overlay.bind(true))
	Action.untargeted.connect(_toggle_interact_overlay.bind(false))
	$HUDButtons.settings_pressed.connect(_toggle_settings)
	
	#Global.smoke_faded.emit("in")
	$InteractOverlay.modulate = Color(0.0, 0.0, 0.0, 0.2)
	$LoadOverride/LoadBlack.visible = true
	
	# Debug visibility
	Global.debug_player_visibility_changed.connect(func():
		$Cursor.visible = Global.debug_player_visible
		$InteractOverlay/InteractCursor.visible = Global.debug_player_visible)
