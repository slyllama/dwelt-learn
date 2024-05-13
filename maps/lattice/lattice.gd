extends "res://lib/world_loader/world_loader.gd"

func _ready():
	super()
	$VentFan/AnimationPlayer.play("Fan")
	$Path3D/PathFollow3D/FourierTest/AnimationPlayer.play("Idle")

func _process(delta):
	$Path3D/PathFollow3D.progress += 0.05
	if $Path3D/PathFollow3D.progress_ratio >= 0.99:
		$Path3D/PathFollow3D.progress = 0.0
