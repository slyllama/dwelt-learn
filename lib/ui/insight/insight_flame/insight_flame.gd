extends Node2D

@export var particles_emitting = true

func _set_trans_state(val):
	var strong_rev_easing = ease(val, 4.8)
	$Glow.modulate.a = val
	$Flame.material.set_shader_parameter("exponent", strong_rev_easing * 10.0)
	$Flame.material.set_shader_parameter("alpha_scale", val)

func open():
	var fade_tween = create_tween()
	$Particles.emitting = true
	fade_tween.tween_method(_set_trans_state, 0.0, 1.0, 0.2)

func _close():
	var fade_tween = create_tween()
	$Particles.emitting = false
	fade_tween.tween_method(_set_trans_state, 1.0, 0.0, 0.25)

func _ready():
	$Particles.emitting = particles_emitting
