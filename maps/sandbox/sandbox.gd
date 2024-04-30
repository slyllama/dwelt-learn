extends "res://lib/world_loader/world_loader.gd"

var og_position

func _ready():
	super()
	og_position = $Player.position

func _input(_event):
	if Input.is_action_just_pressed("test_key"):
		# DEBUG: return to the platform
		$Player.position = og_position
