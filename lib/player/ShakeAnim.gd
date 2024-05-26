extends AnimationPlayer

const MAX_V = 0.24
const MAX_H = 0.05

func shake_with_intensity(intensity = 1.0):
	var anim = get_animation("shake")
	var og_pos = get_parent().target_y_position
	
	anim.track_set_key_value(0, 0, og_pos)
	anim.track_set_key_value(0, 1, og_pos + MAX_V * -intensity)
	anim.track_set_key_value(0, 2, og_pos)
	
	anim.track_set_key_value(1, 1, MAX_H * intensity)
	anim.track_set_key_value(1, 2, MAX_H * -intensity)
	play("shake")

func _ready():
	Global.camera_shaken.connect(shake_with_intensity)
