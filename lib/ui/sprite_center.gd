extends Node2D

@export var debug = false

func set_pos(offset = Vector2.ZERO, lerp_val = 0.0):
	var pos_val = get_window().get_size() / 2.0 * 1.0 / get_window().content_scale_factor + offset
	if lerp_val != 0.0:
		global_position = lerp(global_position, pos_val, lerp_val)
	else: global_position = pos_val

func _ready():
	if debug == false: $FloorDiff.queue_free()
	get_tree().get_root().size_changed.connect(func():
		set_pos())
	set_pos()
