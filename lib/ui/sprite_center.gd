extends Node2D

func _set_pos():
	global_position = get_window().get_size() / 2.0 * 1.0 / get_window().content_scale_factor

func _ready():
	get_tree().get_root().size_changed.connect(func():
		_set_pos())
	_set_pos()
