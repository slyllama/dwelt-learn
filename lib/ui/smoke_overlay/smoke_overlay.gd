extends CanvasLayer

var active = false

func _set_alpha(alpha):
	$BG.material.set_shader_parameter("overall_alpha", alpha)

func activate():
	active = true
	$BG.visible = true
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_alpha, 0.0, 0.7, 0.5)

func deactivate():
	$BG.visible = true
	active = false
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_alpha, 1.0, 0.0, 0.5)
	fade_tween.tween_callback(func():
		if active == false: $BG.visible = false)

func _ready():
	$BG.visible = false
