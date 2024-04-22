extends ColorRect

signal animation_finished

func set_shader_size(ampl):
	(material as ShaderMaterial).set_shader_parameter("size", ampl)

func set_shader_force(force):
	(material as ShaderMaterial).set_shader_parameter("force", force)

func pulse(force = 0.02):
	visible = true
	var size_tween = create_tween()
	var force_tween = create_tween()
	size_tween.tween_method(set_shader_size, 0.15, 0.7, 0.6).set_trans(Tween.TRANS_CIRC)
	force_tween.set_parallel()
	force_tween.tween_method(set_shader_force, force, 0.0, 0.6)
	await force_tween.finished
	visible = false
	emit_signal("animation_finished")

func _ready():
	get_parent().opened.connect(pulse)
