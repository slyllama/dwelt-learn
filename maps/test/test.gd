extends "res://lib/world_loader/world_loader.gd"

func _ready():
	super()
	Global.debug_state = true
	Global.debug_toggled.emit()
	
	$VentFan/AnimationPlayer.play("Fan")
	%Sky.environment.volumetric_fog_enabled = false
