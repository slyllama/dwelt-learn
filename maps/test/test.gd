extends "res://lib/world_loader/world_loader.gd"

func _ready():
	super()
	Global.debug_state = true
	Global.debug_toggled.emit()
	
	$VentFan/AnimationPlayer.play("Fan")
	%Player.position = Vector3(0.0, 3.0, 5.0)
	%Sky.environment.volumetric_fog_enabled = false
	
	print("TEST WORLD")
