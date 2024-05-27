extends CanvasLayer
# "Anime" effect which shows when the player moves

@export var time = 0.1
@export var maximum_alpha = 0.45

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
		if active == true: return
		$AnimeTex.visible = false)

func _ready():
	$AnimeTex.visible = false

var can_move = true
func _process(_delta): # prevent motion when locked
	if get_parent().get_node("Collision").disabled:
		if can_move:
			#active = false
			can_move = false
			anime_out()
	else:
		if !can_move:
			can_move = true
			if Input.is_action_pressed("move_forward"): anime_in()
