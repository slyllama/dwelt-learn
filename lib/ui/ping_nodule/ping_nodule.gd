extends Node3D
# ping_nodule.gd
# Will appear and animate above nearby Insights (as called by WorldLoader),
# disappearing again after a certain time.

var y_target = 2.0

func _set_alpha(val):
	var ev = ease(val, 2.6)
	$Flame.get_surface_override_material(0).set_shader_parameter("alpha_scale", ev)

func _ready():
	_set_alpha(0.0)
	var fade_tween = create_tween()
	fade_tween.tween_method(
		_set_alpha, 0.0, 1.0, 0.8)
	$RemoveTimer.start()

func _on_remove_timer_timeout():
	y_target = 4.0
	var fade_tween = create_tween()
	fade_tween.tween_method(
		_set_alpha, 1.0, 0.0, 0.4)
	fade_tween.tween_callback(queue_free)

func _process(_delta):
	$Flame.position.y = lerp($Flame.position.y, y_target, 0.06)
