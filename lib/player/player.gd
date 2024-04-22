extends CharacterBody3D

@export var hover_height = 3.0
@export var floor_level = 2.0
@export var speed = 5.0
@export var speed_smoothing = 0.08
@export var model_yaw_extent = 20.0

var forward = 0
var side = 0
var target_velocity = Vector3.ZERO
var last_pivot_y_rotation = 0.0
var rotation_diff = 0.0 # difference between pivot and model rotation - used for animation

# Position locking variables
var position_locked = false
var lock_pos = Vector3.ZERO
var lock_cam_clamp = { "x_lower": 0.0, "x_upper": 0.0, "y_lower": 0.0, "y_upper": 0.0 }

# Apply and lock the position and camera rotation of the player, and limit the
# extent to which the player can look around.
#
# - get_lock_pos: the position in the world to snap to
# - get_cam_facing: Vector2([x in degrees][y in degrees] to point toward
# - get_clamp_extent_x: the extent, in degrees, to which the camera can look
#   in the x direction
# - get_clamp_extent_y: the extent, in degrees, to which the camera can look
#   in the y direction

func lock_position(get_lock_pos, get_cam_facing, get_clamp_extent_x, get_clamp_extent_y):
	lock_pos = get_lock_pos
	lock_cam_clamp.x_lower = get_cam_facing.x - get_clamp_extent_x
	lock_cam_clamp.x_upper = get_cam_facing.x + get_clamp_extent_x
	lock_cam_clamp.y_lower = get_cam_facing.y - get_clamp_extent_y
	lock_cam_clamp.y_upper = get_cam_facing.y + get_clamp_extent_y
	
	position_locked = true
	$FloatUpDown.pause()
	$Lemonade/AnimationPlayer.play_backwards("Fly")
	$Stars.amount_ratio = 0.3
	
	%CamPivot.rotation_degrees.y = get_cam_facing.x
	%CamPivot.new_cam_y_rotation = get_cam_facing.x
	$Lemonade.rotation_degrees.y = get_cam_facing.x
	$Lemonade.rotation_degrees.z = 0.0

func unlock_position():
	if (Input.is_action_pressed("move_forward")
		or Input.is_action_pressed("move_back")):
		# Play movement animation if the player is holding down a movement key
		# when leaving the laser
		$Lemonade/AnimationPlayer.play("Fly")
	$FloatUpDown.play("float")
	position_locked = false
	$Stars.amount_ratio = 1.0

func update_debug():
	Global.debug_details_text = ("position = ("
		+ Utilities.fstr(global_position.x) + ", "
		+ Utilities.fstr(global_position.y) + ", "
		+ Utilities.fstr(global_position.z) + ")")
	Global.debug_details_text += "\nmagnitude = " + Utilities.fstr(velocity.length())
	Global.debug_details_text += "\ndirection = " + Utilities.fstr(%CamPivot.rotation_degrees.y, 1)
	Global.debug_details_text += "\u00B0 (" + str(snapped($Lemonade.rotation_degrees.y, 1))  + "\u00B0)"
	Global.debug_details_text += "\nraycast_y_point = " + Utilities.fstr(Global.raycast_y_point)
	if Global.in_area_name != "":
		Global.debug_details_text += ("\n[color=yellow]Over: '" + str(Global.in_area_name) + "'[/color]")

func _ready():
	Global.connect("player_position_locked", lock_position)
	Global.connect("player_position_unlocked", unlock_position)
	
	# Set up for retina
	if DisplayServer.screen_get_size().x > 2000:
#		get_window().size = get_window().size * 1.5
#		get_window().position -= Vector2i(get_window().size.x / 4.0, get_window().size.y / 4.0)
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(load("res://generic/tex/cursor_2x.png"))

func _input(_event):
	if Global.in_keybind_select == true: return
	
	# TODO: debug only
	if Input.is_action_just_pressed("test_key"):
		if position_locked == false:
			lock_position(Vector3(0.0, 4.0, 0.0), Vector2(90.0, 10.0), 40.0, 20.0)
			return
		else: unlock_position()
	
	# No animations if the player's position is locked
	if position_locked == true: return
	
	if Input.is_action_just_pressed("move_forward"):
		$Stars.amount_ratio = 1.0
		$SoundHandler.move()
		$Lemonade/AnimationPlayer.play("Fly")
	if Input.is_action_just_released("move_forward"):
		$Stars.amount_ratio = 0.3
		$SoundHandler.stop_moving()
		$Lemonade/AnimationPlayer.play_backwards("Fly")
	
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
	
	if Global.in_keybind_select == true: return

	if position_locked == true:
		position = lerp(position, lock_pos, 0.2)
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
	
	target_velocity = (-forward * %CamPivot.global_transform.basis.z
		+ -side * %CamPivot.global_transform.basis.x)
	# Strip out the camera looking up/down
	target_velocity = target_velocity.normalized() * Vector3(1, 0, 1) * speed
	
	velocity = lerp(velocity, target_velocity, speed_smoothing)
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

	position.y = lerp(position.y, Global.raycast_y_point + hover_height, 0.07)
	Global.player_position = position
	update_debug()
