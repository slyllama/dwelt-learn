extends "res://lib/world_loader/world_loader.gd"

var on_second_floor = false

func _ready():
	spring_arm_objects = [$Greybox]
	
	super()
	$VentFan/AnimationPlayer.play("Fan")
	$FourierTest/AnimationPlayer.play("Idle")
	
	await get_tree().create_timer(3.0).timeout
	$Music.play()

func _physics_process(_delta):
	if Global.player_position.y > 10.0:
		if on_second_floor == false:
			for node in $FloorPieces.get_children():
				if node.get_node_or_null("Light") != null:
					node.get_node("Light").visible = false
			on_second_floor = true
	else:
		if on_second_floor == true:
			for node in $FloorPieces.get_children():
				if node.get_node_or_null("Light") != null:
					node.get_node("Light").visible = true
			on_second_floor = false

func _on_laser_detector_activated():
	$LaserDetector/PlayDialogue.play()
	Global.camera_shaken.emit()
