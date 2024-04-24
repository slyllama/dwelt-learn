extends "res://lib/world_loader/world_loader.gd"

func _input(_event):
	if Input.is_action_just_pressed("test_key"):
		$PuzzleDoor/AnimationPlayer.play("Hinges")
