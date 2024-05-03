extends "res://lib/world_loader/world_loader.gd"

func _ready():
	super()
	%Player.set_model_scale(0.2)
	$FourierTest/AnimationPlayer.play("Idle")

func _on_laser_detector_activated():
	Global.camera_shaken.emit()
