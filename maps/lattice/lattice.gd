extends "res://lib/world_loader/world_loader.gd"

func _ready():
	spring_arm_objects = [$Greybox]
	
	super()
	$VentFan/AnimationPlayer.play("Fan")
	$FourierTest/AnimationPlayer.play("Idle")
	
	await get_tree().create_timer(3.0).timeout
	$Music.play()
