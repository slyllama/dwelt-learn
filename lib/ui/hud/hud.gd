extends CanvasLayer

func _toggle_interact_overlay(state):
	if state == true:
		$InteractOverlayGlow/Anim.play("pulse")
		var fade_tween = create_tween()
		fade_tween.tween_property(
			$InteractOverlay, "modulate", Color(1.0, 1.0, 1.0, 0.5), 0.2)
		var glow_fade_tween = create_tween()
		glow_fade_tween.tween_property(
			$InteractOverlayGlow, "modulate:a", 1.0, 0.2)
	else:
		$InteractOverlayGlow/Anim.stop()
		var fade_tween = create_tween()
		fade_tween.tween_property(
			$InteractOverlay, "modulate", Color(0.0, 0.0, 0.0, 0.2), 0.2)
		var glow_fade_tween = create_tween()
		glow_fade_tween.tween_property(
			$InteractOverlayGlow, "modulate:a", 0.0, 0.2)

func _ready():
	Global.connect("interact_entered", _toggle_interact_overlay.bind(true))
	Global.connect("interact_left", _toggle_interact_overlay.bind(false))
	
	$InteractOverlay.modulate = Color(0.0, 0.0, 0.0, 0.2)
	$InteractOverlayGlow.modulate.a = 0.2
