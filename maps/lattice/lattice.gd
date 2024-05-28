extends "res://lib/world_loader/world_loader.gd"

var on_second_floor = false
var played_glider_hint = false

func _ready():
	interact_objects = [
		$Elevator,
		$Laser,
		$FourierTest/DialogueArea,
		$Tank2/TankDialogue,
		$LaserDetector/DialogueArea
	]
	spring_arm_objects = [$Greybox]
	super()
	
	####### Custom save data for Lattice #######
	Save.save_loaded.connect(func():
		if Save.get_data(map_name, "laser_siax_orientation") != null:
			$Laser/Cast.rotation_degrees = Save.get_data(map_name, "laser_siax_orientation"))
	proc_save() # trigger save loading now that customs have been added
	
	$Greybox/VentHandler.turn_off()
	$FourierTest/AnimationPlayer.play("Idle")
	$FourierRotate/FourierTest/AnimationPlayer.play("Idle")

func _process(_delta):
	$FourierRotate.rotation_degrees.y += 0.1

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
	if !played_glider_hint:
		if Save.get_data(map_name, "gliding_hint_played") == null:
			played_glider_hint = true
			Global.input_hint_played.emit([{
				"title": "Glide",
				"description": "Soar in updrafts!", 
				"key": ["skill_glide"]
			}], 5.0)
			Save.set_data(map_name, "gliding_hint_played", played_glider_hint)
	$Greybox/VentHandler.turn_on()
	Global.camera_shaken.emit()

func _on_laser_player_left(object_name, cast_rotation):
	Save.set_data(map_name, "laser_" + object_name + "_orientation", cast_rotation)

func _on_laser_detector_deactivated():
	$Greybox/VentHandler.turn_off()
