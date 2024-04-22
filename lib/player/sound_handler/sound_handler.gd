extends Node3D
# Player sound handler
# TODO: get the transitions in and working properly

func lock_position(_get_lock_pos, _get_cam_facing, _get_clamp_extent_x, _get_clamp_extent_y):
	$Speaker.play()

func move():
	pass

func stop_moving():
	pass

func _ready():
	Global.player_position_locked.connect(lock_position)
