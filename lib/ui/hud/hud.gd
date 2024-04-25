extends CanvasLayer

func _toggle_interact_overlay(state):
	if state == true:
		$InteractOverlayGlow.visible = true
		$InteractOverlayGlow/Anim.play("pulse")
		var fade_tween = create_tween()
		fade_tween.tween_property(
			$InteractOverlay, "modulate", Color(1.0, 1.0, 1.0, 0.5), 0.2)
	else:
		$InteractOverlayGlow.visible = false
		$InteractOverlayGlow/Anim.stop()
		var fade_tween = create_tween()
		fade_tween.tween_property(
			$InteractOverlay, "modulate", Color(0.0, 0.0, 0.0, 0.2), 0.2)

func _ready():
	Global.connect("interact_entered", _toggle_interact_overlay.bind(true))
	Global.connect("interact_left", _toggle_interact_overlay.bind(false))
	
	$InteractOverlay.modulate = Color(0.0, 0.0, 0.0, 0.2)
	$InteractOverlayGlow.visible = false
	
	# Present after a second
	await get_tree().create_timer(0.4).timeout
	$FadeOverlay.fade_in()
