extends "res://lib/world_loader/world_loader.gd"

func _ready():
	super()
	$VentFan/AnimationPlayer.play("Fan")
	%Sky.environment.volumetric_fog_enabled = false
