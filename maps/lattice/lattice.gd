extends "res://lib/world_loader/world_loader.gd"

# These will disappear when on the second floor
@onready var first_floor_components = [ $Tanks, $Motes, $Fourier, $Laser, $FourierRotate, $LaserLever ]
@onready var second_floor_components = [ $MemTest ]

func _n(): return

var on_second_floor = false
var played_glider_hint = false

func _set_lever_text():
	if $MemTest/LeverA.state: $MemTest/LeverA/AVis.set_text("Lever A\n[color=green]ON[/color]")
	else: $MemTest/LeverA/AVis.set_text("Lever A\n[color=yellow]OFF[/color]")
	if $MemTest/LeverB.state: $MemTest/LeverB/BVis.set_text("Lever B\n[color=green]ON[/color]")
	else: $MemTest/LeverB/BVis.set_text("Lever B\n[color=yellow]OFF[/color]")

func _ready():
	# Reparent the energy ball to the thruster bone so it maintains the correct position
	var RearThruster = $FourierRotate/FourierTest/FourierSkeleton/Skeleton3D/RearThruster_001
	$FourierRotate/FourierTest/Glow.reparent(RearThruster, false)
	RearThruster.get_node("Glow").position = Vector3.ZERO
	
	interact_objects = [
		$Elevator,
		$Laser,
		$Fourier/DialogueArea,
		$Tanks/Tank2/TankDialogue,
		$LaserDetector/DialogueArea,
		$LaserLever,
		$MemTest/LeverA,
		$MemTest/LeverB,
		$MemTest/LeverJedi ]
	spring_arm_objects = [$Greybox]
	super()

	####### Custom save data for Lattice #######
	Save.save_loaded.connect(func():
		var _laser_orientation = Save.get_data(map_name, "laser_orientation")
		if _laser_orientation: $Laser/Cast.rotation_degrees = _laser_orientation
		#$Laser/Cast.rotation_degrees = _laser_orientation if _laser_orientation else _n()
		var _laser_activated = Save.get_data(map_name, "laser_activated")
		if _laser_activated: $LaserLever.set_state(_laser_activated)
		else: $LaserLever.set_state(false)
		var _lever_a_state = Save.get_data(map_name, "lever_a_state")
		if _lever_a_state: $MemTest/LeverA.set_state(_lever_a_state)
		var _lever_b_state = Save.get_data(map_name, "lever_b_state")
		if _lever_b_state: $MemTest/LeverB.set_state(_lever_b_state)
	)
	proc_save() # trigger save loading now that customs have been added
	_set_lever_text()
	
	# Make sure laser agrees with lever
	$Laser.set_state($LaserLever.state)
	$Greybox/VentHandler.turn_off()
	$Fourier/AnimationPlayer.play("Idle")
	$FourierRotate/FourierTest/AnimationPlayer.play("Idle")
	$MemTest/LeverJedi/AnimationPlayer.play("Idle")

func _process(_delta):
	$FourierRotate.rotation_degrees.y += 0.1

func _physics_process(_delta):
	if Global.player_position.y > 10.0:
		if on_second_floor == false:
			for n in first_floor_components: n.visible = false
			for n in second_floor_components: n.visible = true
			for node in $FloorPieces.get_children():
				if node.get_node_or_null("Light") != null:
					node.get_node("Light").visible = false
			on_second_floor = true
	else:
		if on_second_floor == true:
			for n in first_floor_components: n.visible = true
			for n in second_floor_components: n.visible = false
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

func _on_laser_player_left(cast_rotation):
	Save.set_data(map_name, "laser_orientation", cast_rotation)

func _on_laser_detector_deactivated():
	$Greybox/VentHandler.turn_off()

func _on_lever_a_state_set(state):
	Save.set_data(map_name, "lever_a_state", state)
	_set_lever_text()

func _on_lever_b_state_set(state):
	Save.set_data(map_name, "lever_b_state", state)
	_set_lever_text()

func _on_laser_lever_state_set(state):
	if state: $Laser/Vis.set_text("Laser (ON)")
	else: $Laser/Vis.set_text("Laser (OFF)")
	Save.set_data(map_name, "laser_activated", state)
	$Laser.set_state(state)
