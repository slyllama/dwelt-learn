extends Node2D

@export var debug = false
@export var keep_y = false

var og_y_pos = 0.0

func set_pos(offset = Vector2.ZERO, lerp_val = 0.0):
	var pos_val = get_window().get_size() / 2.0 * 1.0 / get_window().content_scale_factor + offset
	if keep_y: pos_val.y = og_y_pos
	if lerp_val != 0.0:
		global_position = lerp(global_position, pos_val, lerp_val)
	else: global_position = pos_val

func _ready():
	og_y_pos = global_position.y
	if debug == false: $FloorDiff.queue_free()
	get_tree().get_root().size_changed.connect(func():
		set_pos())
	set_pos()
