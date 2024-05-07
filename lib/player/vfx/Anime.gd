extends CanvasLayer
# "Anime" effect which shows when the player moves

@export var time = 0.1
@export var maximum_alpha = 0.2

var active = false

func _set_alpha(a):
	$AnimeTex.material.set_shader_parameter("modulate_a", a)

func anime_in():
	active = true
	$AnimeTex.material.set_shader_parameter("modulate_a", 0.0)
	$AnimeTex.visible = true
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_alpha, 0.0, maximum_alpha, time)

func anime_out():
	active = false
	$AnimeTex.material.set_shader_parameter("modulate_a", maximum_alpha)
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_alpha, maximum_alpha, 0.0, time)
	fade_tween.tween_callback(func():
		if active == true:
			return
		$AnimeTex.visible = false)

func _ready():
	$AnimeTex.visible = false
