extends Node3D

func _set_trans(val):
	$Screw/Plane.get_active_material(0).set_shader_parameter("alpha_scale", 1.0 - val)
	$Screw/Plane.get_active_material(0).set_shader_parameter("exponent", val * 10.0)
	$Screw/Plane.get_active_material(0).set_shader_parameter("uv_x_pos", val * 3.4 - 0.1)

func fire():
	var fire_tween = create_tween()
	fire_tween.tween_method(_set_trans, 0.0, 1.0, 2.0)
	fire_tween.tween_callback(queue_free)
