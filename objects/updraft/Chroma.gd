extends ColorRect

@export var intensity_multiplier = 20.0

func _set_aberration(intensity):
	material.set_shader_parameter(
		"r_displacement:x", intensity * intensity_multiplier)
	material.set_shader_parameter(
		"g_displacement:x", intensity * intensity_multiplier)
	material.set_shader_parameter(
		"b_displacement:x", intensity * -intensity_multiplier)

func updraft():
	var aberrate_tween = create_tween()
	visible = true
	aberrate_tween.tween_method(_set_aberration, 1.0, 0.0, 0.5)
	aberrate_tween.tween_callback(func(): visible = false)

func _ready():
	visible = false
	_set_aberration(0.0)
