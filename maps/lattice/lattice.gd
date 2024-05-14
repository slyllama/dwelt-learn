extends "res://lib/world_loader/world_loader.gd"

func _ready():
	spring_arm_objects = [$Greybox]
	
	super()
	$VentFan/AnimationPlayer.play("Fan")
	$FourierTest/AnimationPlayer.play("Idle")
