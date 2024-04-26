extends Node3D
# Player sound handler
# TODO: get the transitions in and working properly

func move():
	$EngineIdle.stop()
	$EngineFly.play()

func stop_moving():
	$EngineFly.stop()
	$EngineIdle.play()

func _ready():
	stop_moving()
