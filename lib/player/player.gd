extends CharacterBody3D

## Base player speed.
@export_category("Player Physics")
@export var speed = 5.0
@export var hover_height = 3.0
## Player friction; not recommended to change this unless necessary.
@export var speed_smoothing = 0.08
## The amount, in degrees, that the player model will yaw in response to
## rotation and strafing.
@export var model_yaw_extent = 20.0
## The rate at which the player will hover up when the 'glide' key is pressed.
@export var glide_rate = 0.04
## The maximum upward force the craft will generate while gliding before it
## hovers there.
@export var max_gliding_force = 0.5

@onready var Radar = $Lemonade/StyxArmature/Skeleton3D/BaseRing/Radar
@onready var RadarAnim = $Lemonade/StyxArmature/Skeleton3D/BaseRing/Radar/AnimationPlayer

var forward = 0
var side = 0
var target_velocity = Vector3.ZERO
var last_pivot_y_rotation = 0.0
var rotation_diff = 0.0 # difference between pivot and model rotation - used for animation
var radar_open = false

var glide = false
var glide_val = 0.0

# Position locking variables
var position_locked = false
var lock_pos = Vector3.ZERO
var lock_cam_clamp = { "x_lower": 0.0, "x_upper": 0.0, "y_lower": 0.0, "y_upper": 0.0 }

func set_model_scale(new_scale):
	$Lemonade.scale = Vector3(new_scale, new_scale, new_scale)

func open_radar():
	radar_open = true
	Radar.visible = true
	RadarAnim.play("RadarKeyAction")

func close_radar():
	radar_open = false
	RadarAnim.play_backwards("RadarKeyAction")
	await RadarAnim.animation_finished
	if radar_open == false: # skip if player has gone back into an interact area
		Radar.visible = false

func lock_position(get_lock_pos, get_cam_facing):
	position_locked = true
	$Collision.disabled = true
	
	lock_pos = get_lock_pos
	$FloatUpDown.pause()
	$Lemonade/AnimationPlayer.play_backwards("Fly")
	$Stars.amount_ratio = 0.3
	$Lemonade.rotation_degrees.y = get_cam_facing.x
	$Lemonade.rotation_degrees.z = 0.0
	
	last_pivot_y_rotation = get_cam_facing.x
	position = lock_pos # should only do this once

func unlock_position():
	position_locked = false
	
	if (Input.is_action_pressed("move_forward")
		or Input.is_action_pressed("move_back")):
		# Play movement animation if the player is holding down a movement key
		# when leaving the laser
		$Lemonade/AnimationPlayer.play("Fly")
	$FloatUpDown.play("float")
	
	await get_tree().create_timer(0.5).timeout
	$Collision.disabled = false

func update_debug():
	Global.debug_details_text = ("position = ("
		+ Utilities.fstr(global_position.x) + ", "
		+ Utilities.fstr(global_position.y) + ", "
		+ Utilities.fstr(global_position.z) + ")")
	Global.debug_details_text += "\nmagnitude = " + Utilities.fstr(velocity.length())
	Global.debug_details_text += "\ndirection = " + Utilities.fstr(%CamPivot.rotation_degrees.y, 1)
	Global.debug_details_text += "\u00B0 (" + str(snapped($Lemonade.rotation_degrees.y, 1))  + "\u00B0)"
	Global.debug_details_text += "\nraycast_y_point = " + Utilities.fstr(Global.raycast_y_point)
	if $Collision.disabled == true:
		Global.debug_details_text += "\n[color=red]Collision disabled[/color]"
	Global.debug_details_text += "\n\nAction.active = " + str(Action.active)
	if Action.last_target != "":
		Global.debug_details_text += "\nAction.last_target = " + str(Action.last_target)
	if Action.target != "":
		Global.debug_details_text += "\n[color=yellow]Action.target = " + str(Action.target) + "[/color]"

func _ready():
	Global.connect("player_position_locked", lock_position)
	Global.connect("player_position_unlocked", unlock_position)
	Action.targeted.connect(open_radar)
	Action.untargeted.connect(close_radar)
	Radar.visible = false

func _input(_event):
	if Global.in_keybind_select == true: return
	# No animations if the player's position is locked
	if position_locked == true: return
	
	if Input.is_action_just_pressed("skill_glide"):
		Action.glide_pressed.emit()
		Action.in_glide = true
	if Input.is_action_just_released("skill_glide"):
		Action.in_glide = false
	
	# TODO: this all should eventually be in its own module
	if Input.is_action_just_pressed("move_forward"):
		$CamPivot.fov_offset = 5.0 # shift the camera back a little when moving
		$Stars.amount_ratio = 1.0
		if Global.settings.fancy_particles == true:
			$Lemonade/StyxArmature/Skeleton3D/Tails_001/Trail.emitting = true
			$Lemonade/StyxArmature/Skeleton3D/Tails_001/Trail2.emitting = true
		$SoundHandler.move()
		$Lemonade/AnimationPlayer.play("Fly")
		$Anime.anime_in()
	if Input.is_action_just_released("move_forward"):
		$CamPivot.fov_offset = 0.0
		$Stars.amount_ratio = 0.3
		$Lemonade/StyxArmature/Skeleton3D/Tails_001/Trail.emitting = false
		$Lemonade/StyxArmature/Skeleton3D/Tails_001/Trail2.emitting = false
		$SoundHandler.stop_moving()
		$Lemonade/AnimationPlayer.play_backwards("Fly")
		$Anime.anime_out()
	
	if Input.is_action_just_pressed("move_back"):
		$Stars.amount_ratio = 1.0
		$SoundHandler.move()
		$Lemonade/AnimationPlayer.play("Fly")
	if Input.is_action_just_released("move_back"):
		$Stars.amount_ratio = 0.3
		$SoundHandler.stop_moving()
		$Lemonade/AnimationPlayer.play_backwards("Fly")

func _physics_process(_delta):
	forward = 0
	side = 0
	rotation_diff = 0.0
	var strafe_diff = 0.0
	
	if Action.in_glide == true: glide_val = 1.3
	else: glide_val = 0.0
	
	if Global.in_keybind_select == true: return
	position += Global.linear_movement_override
	
	if position_locked == true:
		Global.player_position = position
		update_debug()
		return
	
	# If the position is locked, nothing happens after this point
	if Input.is_action_pressed("move_forward"): forward += 1
	if Input.is_action_pressed("move_back"): forward -= 1
	if Input.is_action_pressed("strafe_left"):
		strafe_diff += 10.0
		side += 0.5
	if Input.is_action_pressed("strafe_right"):
		strafe_diff -= 10.0
		side -= 0.5
	
	if glide == true:
		if glide_val < max_gliding_force: glide_val += glide_rate
		else: glide_val -= glide_rate
	glide_val = clamp(glide_val, 0.0, max_gliding_force)

	target_velocity = forward * Vector3.FORWARD * $CamPivot.global_transform.basis
	target_velocity += side * Vector3.RIGHT * $CamPivot.global_transform.basis
	target_velocity = target_velocity.normalized() * Vector3(-1, 0, 1) * speed
	
	# Uses the difference between the y-cast and the player's y-position to
	# generate a damping value, y_diff
	velocity = lerp(velocity, target_velocity, speed_smoothing)
	velocity.y -= Global.gravity / 1.5
	var y_diff = Global.player_position.y - Global.raycast_y_point
	if y_diff < hover_height: velocity.y += hover_height - y_diff
	else: velocity.y += glide_val
	
	move_and_slide()
	
	if velocity.length() > 1.0:
		rotation_diff = Utilities.short_angle_dist(
			%CamPivot.rotation.y, $Lemonade.rotation.y) * -0.25
		last_pivot_y_rotation = %CamPivot.rotation.y
	
	# Robot slowly turns to match the camera
	$Lemonade.rotation.y = lerp_angle(
		$Lemonade.rotation.y, last_pivot_y_rotation, 0.06)
	# Robot yaws to match rotation rate and strafe
	$Lemonade.rotation.z = lerpf(
		$Lemonade.rotation.z, rotation_diff + strafe_diff * 0.02, 0.06)
	$Lemonade.rotation_degrees.z = clampf(
		$Lemonade.rotation_degrees.z, -model_yaw_extent, model_yaw_extent)
	
	Global.player_position = position
	update_debug()
