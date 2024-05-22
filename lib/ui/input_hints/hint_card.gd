extends Panel

@export var title: String = "Input Hint"
@export var description: String = "Input hint description."
@export var key_text: String = "#"

func _set_trans(val, white = true):
	var ease_val = ease(val, 2.0)
	modulate.a = val
	if white == true: material.set_shader_parameter("base_color", 1.0 - ease_val)
	material.set_shader_parameter("alpha_scale", val * 0.85)

func fade_out(white = true):
	var fade = create_tween()
	fade.tween_method(_set_trans.bind(white), 1.0, 0.0, 0.3)

func _ready():
	modulate.a = 1.0
	$Title.text = str(title).to_upper()
	$Description.text = description
	$Panel/Key.text = Utilities.cntr(str(key_text).to_upper())
	
	var fade = create_tween()
	fade.tween_method(_set_trans, 0.0, 1.0, 0.2)
