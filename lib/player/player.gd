extends CharacterBody3D

@export_category("Player Physics")
@export var speed = 5.0
@export var hover_height = 3.0
@export var speed_smoothing = 0.08
@export var glide_rate = 0.04
@export var max_gliding_force = 0.5

var forward = 0
var side = 0
var target_velocity = Vector3.ZERO

var glide = false
var glide_val = 0.0

# Position locking variables
var position_locked = false
var lock_pos = Vector3.ZERO
var lock_dir = Vector3.ZERO
var lock_cam_clamp = { "x_lower": 0.0, "x_upper": 0.0, "y_lower": 0.0, "y_upper": 0.0 }

func lock_position(get_lock_pos, get_cam_facing):
	position_locked = true
	$Collision.disabled = true
	$ModelHandler.stop_moving()
	lock_pos = get_lock_pos
	lock_dir = get_cam_facing
	position = lock_pos # should only do this once

func unlock_position():
	position_locked = false
	
	if (Input.is_action_pressed("move_forward")
		or Input.is_action_pressed("move_back")):
		# Play movement animation if the player is holding down a movement key
		# when leaving the laser
		$ModelHandler.start_moving()

	await get_tree().create_timer(0.5).timeout
	$Collision.disabled = false

func update_debug():
	Global.debug_details_text = ("Position: "
		+ Utilities.fstr(global_position.x) + ", "
		+ Utilities.fstr(global_position.y) + ", "
		+ Utilities.fstr(global_position.z))
	
	Global.debug_details_text += "\nGround speed: " + Utilities.fstr(velocity.length())
	Global.debug_details_text += "\nVertical speed: " + Utilities.fstr(Global.player_y_velocity * -1.0)
	Global.debug_details_text += "\nDirection: " + Utilities.fstr(%CamPivot.rotation_degrees.y, 1)
	Global.debug_details_text += "\u00B0 (" + str(snapped($ModelHandler.rotation_degrees.y, 1))  + "\u00B0)"
	
	if Action.target != "": Global.debug_details_text += "\n[color=yellow]Action target: " + str(Action.target)
	if Action.last_target != "": Global.debug_details_text += "\n[color=yellow]Last action target: " + str(Action.last_target)
	if Action.active: Global.debug_details_text += "\n[color=yellow]In action: true"
	if $Collision.disabled: Global.debug_details_text += "\n[color=red]Collision disabled[/color]"
	if !Global.can_move: Global.debug_details_text += "\n[color=red]Movement disabled[/color]"

var spring_arm_mask

func _ready():
	spring_arm_mask = $CamPivot/CamArm.collision_mask
	Global.connect("player_position_locked", lock_position)
	Global.connect("player_position_unlocked", unlock_position)
	
	Action.activated.connect(func(_toggle): $CamPivot/CamArm.collision_mask = 0)
	Global.dialogue_played.connect(func(_i): $CamPivot/CamArm.collision_mask = spring_arm_mask)
	Action.deactivated.connect(func(): $CamPivot/CamArm.collision_mask = spring_arm_mask)

func _input(_event):
	# No animations if the player's position is locked
	if position_locked or !Global.can_move: return
	if Global.in_keybind_select: return

	if (Input.is_action_just_pressed("skill_glide")
		or Input.is_action_just_pressed("right_shoulder")):
		Action.glide_pressed.emit()
		Action.in_glide = true
	if (Input.is_action_just_released("skill_glide")
		or Input.is_action_just_released("right_shoulder")):
		Action.in_glide = false
	
	# TODO: this all should eventually be in its own module
	if Input.is_action_just_pressed("move_forward"):
		$CamPivot.fov_offset = 5.0 # shift the camera back a little when moving
		$ModelHandler.start_moving()
		$Anime.anime_in()
	if Input.is_action_just_released("move_forward"):
		$CamPivot.fov_offset = 0.0
		$ModelHandler.stop_moving()
		$Anime.anime_out()
	
	if Input.is_action_just_pressed("move_back"): $ModelHandler.start_moving()
	if Input.is_action_just_released("move_back"): $ModelHandler.stop_moving()

var c = 0

func _physics_process(_delta):
	forward = 0
	side = 0
	
	if Global.in_keybind_select == true: return
	position += Global.linear_movement_override

	if Action.in_glide == true: glide_val = 1.3
	else: glide_val = 0.0
	if position_locked == true:
		Global.player_position = position
		update_debug()
		return

	# If the position is locked, nothing happens after this point
	if Input.is_action_pressed("move_forward"): forward += 1
	if Input.is_action_pressed("move_back"): forward -= 1
	if Input.is_action_pressed("strafe_left"): side += 0.5
	if Input.is_action_pressed("strafe_right"): side -= 0.5
	forward -= Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	side -= Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * 0.5
	
	forward = clamp(forward, -1.0, 1.0)
	side = clamp(side, -1.0, 1.0)
	
	if Action.in_glide == true and Global.player_y_velocity < -1.0:
		forward += 0.15
	
	if glide == true:
		if glide_val < max_gliding_force: glide_val += glide_rate
		else: glide_val -= glide_rate
	glide_val = clamp(glide_val, 0.0, max_gliding_force)

	target_velocity = forward * Vector3.FORWARD * $CamPivot.global_transform.basis
	target_velocity += side * Vector3.RIGHT * $CamPivot.global_transform.basis
	target_velocity = target_velocity.normalized() * Vector3(-1, 0, 1) * speed
	
	if Global.can_move == false:
		target_velocity = Vector3.ZERO
	
	# Uses the difference between the y-cast and the player's y-position to
	# generate a damping value, y_diff
	velocity = lerp(velocity, target_velocity, speed_smoothing)
	velocity.y -= Global.gravity / 1.5
	var y_diff = Global.player_position.y - Global.raycast_y_point
	if y_diff < hover_height: velocity.y += hover_height - y_diff
	else: velocity.y += glide_val
	
	move_and_slide()
	
	Global.player_position = global_position
	Global.insight_camera_position = $CamPivot/Camera.unproject_position(
		Global.insight_current_position)
	Global.player_y_velocity = velocity.y
	if c == 30:
		if velocity.y > -1.0 and velocity.y < 1.0:
			Global.player_ground_position = global_position
		c = 0
	update_debug()
	c += 1
