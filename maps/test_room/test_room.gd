extends "res://lib/world_loader/world_loader.gd"

func toggle_door_test(door_test_state):
	Global.camera_shaken.emit()
	if door_test_state == true:
		$PuzzleDoor/AnimationPlayer.play("Hinges")
	else:
		$PuzzleDoor/AnimationPlayer.play_backwards("Hinges")
	$PuzzleDoor/Closed/CollisionShape3D.disabled = door_test_state

func _ready():
	$PuzzleDoor/Closed.set_collision_layer_value(2, true)
	$LaserDetector.activated.connect(toggle_door_test.bind(true))
	$LaserDetector.deactivated.connect(toggle_door_test.bind(false))
