extends Node3D
# Player sound handler
# TODO: get the transitions in and working properly

@export var lowest_volume = 0.5

var target_vol = lowest_volume

func move():
	$EngineIdle.stop()
	$EngineFly.play()
	target_vol = 1.0

func stop_moving():
	$EngineFly.stop()
	$EngineIdle.play()
	target_vol = lowest_volume

func _ready():
	$EngineIdle.volume_db = target_vol
	$EngineFly.volume_db = target_vol
	
	$EngineIdle.play()

func _process(_delta):
	$EngineIdle.volume_db = lerp($EngineIdle.volume_db, linear_to_db(target_vol), 0.05)
	$EngineFly.volume_db = lerp($EngineFly.volume_db, linear_to_db(target_vol), 0.05)
