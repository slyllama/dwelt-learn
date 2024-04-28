extends Node3D

@export var camera_sensitivity = 0.65
@export var camera_smoothing = 0.5
@export var zoom_increment = 0.4
@export var min_zoom_extent = 2.0
@export var max_zoom_extent = 6.7

@onready var Cast = get_node("CamArm/Camera/Cast")

var new_cam_y_rotation = 0.0
var new_cam_x_rotation = 0.0
var target_y_position
var camera_distance = 3.7

var right_mouse_down = false
var mouse_offset = Vector2.ZERO
var last_mouse_offset = mouse_offset

var fov_offset = 0.0

# click_mouse_pos is used to measure the amount the mouse has moved while the
# mouse is down. True to GW2 style, camera movement will only activate after
# the mouse have moved while down - not just when a button is pressed
var click_mouse_pos = Vector2.ZERO
var click_mouse_pos_diff = Vector2.ZERO

func _shake_cam(): $ShakeAnim.play("shake")

func _ready():
	Global.camera_shaken.connect(_shake_cam)
	# Apply the original rotation of the pivot point so there won't be any
	# awkward snaps
	new_cam_y_rotation = rotation_degrees.y
	new_cam_x_rotation = rotation_degrees.x
	target_y_position = $CamArm/Camera.v_offset
	camera_distance = $CamArm.spring_length

	# Zoom in a bit
	for _i in 2:
		camera_distance -= zoom_increment
		target_y_position -= 0.1

func _input(event):
	if Global.dragging_control == true: return
	
	# Only move the camera after the actuation threshold has been passed --
	# see click_mouse_pos_diff above. Should work for both left and right click
	if event is InputEventMouseMotion:
		click_mouse_pos_diff = click_mouse_pos - get_window().get_mouse_position()
		if Input.is_action_pressed("right_click") or Input.is_action_pressed("click"):
			if click_mouse_pos_diff.length() > 2.0:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				right_mouse_down = true
	if Input.is_action_just_pressed("right_click") or Input.is_action_just_pressed("click"):
		if right_mouse_down == false:
			click_mouse_pos_diff = Vector2.ZERO
			click_mouse_pos = get_window().get_mouse_position()
	if Input.is_action_just_released("right_click") or Input.is_action_just_released("click"):
		if right_mouse_down == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			right_mouse_down = false
	
	if event is InputEventMouseMotion and right_mouse_down == true:
		mouse_offset = event.relative
		if mouse_offset.x < 2.0 and mouse_offset.x > -2.0:
			mouse_offset.x = 0.0
		if mouse_offset.y < 2.0 and mouse_offset.y > -2.0:
			mouse_offset.y = 0.0
	
	if Global.in_keybind_select == true: return
	
	# Process zooms
	if Input.is_action_just_pressed("zoom_in"):
		if camera_distance - zoom_increment > min_zoom_extent:
			camera_distance -= zoom_increment
			target_y_position -= 0.1
	elif Input.is_action_just_pressed("zoom_out"):
		if camera_distance + zoom_increment < max_zoom_extent:
			camera_distance += zoom_increment
			target_y_position += 0.1

func _process(_delta):
	# Zoom camera
	$CamArm.spring_length = lerpf($CamArm.spring_length, camera_distance, 0.1)
	$CamArm/Camera.v_offset = lerpf($CamArm/Camera.v_offset, target_y_position, 0.05)
	
	# Get what the player is looking up by reading the results of a raycast
	# Sets the var to 'null' if looking at nothing
	if Cast.is_colliding(): Global.looking_at = Cast.get_collision_point()
	else: Global.looking_at = null
	
	# TODO: make sure this doesn't become too performant
	$CamArm/Camera.fov = lerp($CamArm/Camera.fov, Global.settings.fov + fov_offset, 0.04)
	
	last_mouse_offset = mouse_offset
	if right_mouse_down == true:
		new_cam_y_rotation += -mouse_offset.x / 1.5 * camera_sensitivity
		new_cam_x_rotation += -mouse_offset.y / 2.0 * camera_sensitivity
		
		# Clamp the camera's rotation when the player is locked into position
		#if get_parent().position_locked == true:
			#new_cam_y_rotation = lerp(new_cam_y_rotation, clampf(
				#new_cam_y_rotation,
				#get_parent().lock_cam_clamp.x_lower,
				#get_parent().lock_cam_clamp.x_upper), 0.1)
			#new_cam_x_rotation = clampf(
				#new_cam_x_rotation,
				#get_parent().lock_cam_clamp.y_lower,
				#get_parent().lock_cam_clamp.y_upper)
		
		rotation_degrees.y = lerpf(
			rotation_degrees.y, new_cam_y_rotation, camera_smoothing)
		rotation_degrees.x = lerpf(
			rotation_degrees.x, new_cam_x_rotation, camera_smoothing)
		
		# Prevent weird interactions with floor/top of axis
		rotation_degrees.x = clampf(
			rotation_degrees.x, -60.0, 45.0)

		# Ensure that the camera will never get stuck in an eternally rotating situation
		if last_mouse_offset == mouse_offset:
			mouse_offset = Vector2.ZERO
