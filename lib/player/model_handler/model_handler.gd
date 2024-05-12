extends Node3D

const roll_extent = 20.0

@onready var trail_L = $Euclid/EuclidArmature/Skeleton3D/Wing_L/Wing_L/Trail3D
@onready var trail_R = $Euclid/EuclidArmature/Skeleton3D/Wing_R/Wing_R/Trail3D2

var anim_moving = false
var ry_delta = 0.0
var ry_last = 0.0
var radar_open = true

var root
var root_cam_pivot

var engine_ratio = 0.0

func open_radar():
	radar_open = true
	$Radar.visible = true
	$Radar/AnimationPlayer.play("RadarKeyAction")

func close_radar():
	radar_open = false
	$Radar/AnimationPlayer.play_backwards("RadarKeyAction")
	await $Radar/AnimationPlayer.animation_finished
	if radar_open == false: # skip if player has gone back into an interact area
		$Radar.visible = false


func start_moving():
	engine_ratio = 1.0
	anim_moving = true
	$Euclid/AnimationTree["parameters/conditions/is_flying"] = true
	$Euclid/AnimationTree["parameters/conditions/not_flying"] = false
	$Stars.amount_ratio = 1.0

func stop_moving():
	engine_ratio = 0.0
	anim_moving = false
	$Euclid/AnimationTree["parameters/conditions/is_flying"] = false
	$Euclid/AnimationTree["parameters/conditions/not_flying"] = true
	$Stars.amount_ratio = 0.3

func _ready():
	root = get_parent()
	root_cam_pivot = root.get_node_or_null("CamPivot")
	
	Action.targeted.connect(open_radar)
	Action.untargeted.connect(close_radar)

func _process(_delta):
	$IdleSound.volume_db = linear_to_db(lerp(db_to_linear($IdleSound.volume_db), 1.0 - engine_ratio, 0.1))
	$RunSound.volume_db = linear_to_db(lerp(db_to_linear($RunSound.volume_db), engine_ratio, 0.1))
	
	if root == null: return
	if root.position_locked == true:
		rotation.z = 0.0
		rotation_degrees.y = root.lock_dir.x
		trail_L.enabled = false
		trail_R.enabled = false
		return
	
	if trail_L.enabled == false: trail_L.reenable()
	if trail_R.enabled == false: trail_R.reenable()
	
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
