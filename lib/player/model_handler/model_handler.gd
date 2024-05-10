extends Node3D

const roll_extent = 20.0

var anim_moving = false
var ry_delta = 0.0
var ry_last = 0.0

var root
var root_cam_pivot

func start_moving():
	anim_moving = true
	$Euclid/AnimationPlayer.play("Fly")
	$Stars.amount_ratio = 1.0

func stop_moving():
	anim_moving = false
	$Euclid/AnimationPlayer.play_backwards("Fly")
	$Stars.amount_ratio = 0.3

func _ready():
	root = get_parent()
	root_cam_pivot = root.get_node_or_null("CamPivot")
	$Euclid/AnimationPlayer.play("Idle")
	$Euclid/AnimationPlayer.animation_finished.connect(func(anim):
		if anim == "Fly" and !anim_moving:
			$Euclid/AnimationPlayer.play("Idle"))

func _process(_delta):
	if root == null: return
	if root.position_locked == true: return
	
	var roll_delta = 0.0
	ry_delta = 0.0
	
	if root.velocity.length() > 1.0:
		ry_delta = Utilities.short_angle_dist(
			root_cam_pivot.rotation.y, rotation.y) * -0.25
		ry_last = root_cam_pivot.rotation.y
	
	if Input.is_action_pressed("strafe_left"): roll_delta += 10.0
	if Input.is_action_pressed("strafe_right"): roll_delta -= 10.0
	
	# Slowly turns to match the camera
	rotation.y = lerp_angle(rotation.y, ry_last, 0.06)
	
	rotation.z = lerpf(
		rotation.z, ry_delta + roll_delta * 0.02, 0.06)
	rotation_degrees.z = clampf(
		rotation_degrees.z, -roll_extent, roll_extent)
