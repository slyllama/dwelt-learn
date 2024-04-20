extends Node3D
# Player sound handler
# TODO: get the transitions in and working properly

func move(): # transition through acceleration to a moving sound
	$EngineIdle.stop()
	$EngineRun.play()

func stop_moving():
	$EngineRun.stop()
	$EngineIdle.play()

func _ready():
	$EngineIdle.play()
