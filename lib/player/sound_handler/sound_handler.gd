extends Node3D
# Player sound handler
# TODO: get the transitions in and working properly

func lock_position(_get_lock_pos, _get_cam_facing, _get_clamp_extent_x, _get_clamp_extent_y):
	$Speaker.play()

func move():
	$EngineIdle.stop()
	$EngineFly.play()

func stop_moving():
	$EngineFly.stop()
	$EngineIdle.play()

func _ready():
	stop_moving()
	Global.player_position_locked.connect(lock_position)
