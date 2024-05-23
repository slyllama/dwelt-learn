extends Node3D

@export var camera_sensitivity = 0.65
@export var camera_smoothing = 0.5
@export var zoom_increment = 0.4
@export var min_zoom_extent = 2.0
@export var max_zoom_extent = 6.7

var new_cam_y_rotation = 0.0
var new_cam_x_rotation = 0.0
var target_y_position
var camera_distance = 3.7
var camera_bounce = 0.35

var right_mouse_down = false
var mouse_offset = Vector2.ZERO
var last_mouse_offset = mouse_offset

var fov_offset = 0.0

# click_mouse_pos is used to measure the amount the mouse has moved while the
# mouse is down. True to GW2 style, camera movement will only activate after
# the mouse have moved while down - not just when a button is pressed
var click_mouse_pos = Vector2.ZERO
var click_mouse_pos_diff = Vector2.ZERO

func _zoom(dir, zoom_scale = 1.0):
	if dir == "in":
		if camera_distance - zoom_increment * zoom_scale > min_zoom_extent:
			camera_distance -= zoom_increment * zoom_scale
			$CamArm/CamAttach/XCast.target_position.z += zoom_increment * zoom_scale
			target_y_position -= 0.2 * zoom_scale
	elif dir == "out":
		if camera_distance + zoom_increment * zoom_scale < max_zoom_extent:
			camera_distance += zoom_increment * zoom_scale
			$CamArm/CamAttach/XCast.target_position.z -= zoom_increment * zoom_scale
			target_y_position += 0.2 * zoom_scale

func _shake_cam(): $ShakeAnim.play("shake")

func _ready():
	Global.camera_shaken.connect(_shake_cam)
	# Apply the original rotation of the pivot point so there won't be any
	# awkward snaps
	new_cam_y_rotation = rotation_degrees.y
	new_cam_x_rotation = rotation_degrees.x
	target_y_position = 1.2
	camera_distance = $CamArm.spring_length

# Prevents mouse capturing starting again when the cursor leaves the panel
var mouse_in_settings_menu = false

func _input(event):
	if Global.dragging_control == true: return
	
	# Only move the camera after the actuation threshold has been passed --
	# see click_mouse_pos_diff above. Should work for both left and right click
	if event is InputEventMouseMotion:
		click_mouse_pos_diff = click_mouse_pos - get_window().get_mouse_position()
		if Input.is_action_pressed("right_click") or Input.is_action_pressed("click"):
			if mouse_in_settings_menu == true: return
			if click_mouse_pos_diff.length() > 2.0:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				right_mouse_down = true
				if Global.mouse_is_captured == false:
					Global.mouse_is_captured = true
					Global.mouse_captured.emit()
	
	if Input.is_action_just_pressed("right_click") or Input.is_action_just_pressed("click"):
		mouse_in_settings_menu = Global.mouse_in_settings_menu
		if right_mouse_down == false:
			click_mouse_pos_diff = Vector2.ZERO
			click_mouse_pos = get_window().get_mouse_position()
	
	if Input.is_action_just_released("right_click") or Input.is_action_just_released("click"):
		mouse_in_settings_menu = Global.mouse_in_settings_menu
		if Global.mouse_is_captured == true:
				Global.mouse_is_captured = false
				Global.mouse_released.emit()
		if right_mouse_down == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			right_mouse_down = false
	
	if event is InputEventMouseMotion and right_mouse_down == true:
		mouse_offset = event.relative
		if mouse_offset.x < 2.0 and mouse_offset.x > -2.0:
			mouse_offset.x = 0.0
		if mouse_offset.y < 2.0 and mouse_offset.y > -2.0:
			mouse_offset.y = 0.0

	# Process zooms
	if Global.in_keybind_select == true: return
	if Global.mouse_in_settings_menu == true: return
	
	if Input.is_action_just_pressed("zoom_in"): _zoom("in")
	elif Input.is_action_just_pressed("zoom_out"): _zoom("out")

func _process(_delta):
	Global.camera_y_rotation = rotation_degrees.y
	
	if !Global.settings_opened and !Action.active:
		if Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_UP): _zoom("in", 0.25)
		elif Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_DOWN): _zoom("out", 0.25)
	
	$Camera.position = lerp(
		$Camera.position, $CamArm/CamAttach.position + Vector3(1.0, 0.0, 0.0), 0.06)
	
	# Position smoothing - more intense when gliding
	if Action.in_glide == true: camera_bounce = 1.0
	else: camera_bounce = 0.35
	var target_y_pos = 1.15 - clamp(Global.player_y_velocity * camera_bounce, -1.0, 1.0)
	position.y = lerp(position.y, target_y_pos, 0.035)
	
	# Adjust camera zoom and FOV
	$CamArm.spring_length = lerpf($CamArm.spring_length, camera_distance, 0.1)
	$Camera.v_offset = lerpf($Camera.v_offset, target_y_position, 0.05)
	$Camera.fov = lerp($Camera.fov, Global.settings.fov + fov_offset, 0.04)
	
	last_mouse_offset = mouse_offset
	# Rotate the camera by using the mouse or the controller.
	
	new_cam_y_rotation += -mouse_offset.x / 1.5 * camera_sensitivity
	new_cam_x_rotation += -mouse_offset.y / 2.0 * camera_sensitivity
	new_cam_y_rotation -= Input.get_joy_axis(0, JOY_AXIS_LEFT_X) * camera_sensitivity * 3.5
	new_cam_x_rotation += Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) * camera_sensitivity * 1.2
	
	# Apply and clamp camera rotation
	rotation_degrees.y = lerpf(rotation_degrees.y, new_cam_y_rotation, camera_smoothing)
	rotation_degrees.x = lerpf(rotation_degrees.x, new_cam_x_rotation, camera_smoothing)
	rotation_degrees.x = clampf(rotation_degrees.x, -60.0, 45.0)

	# (Ensure that the camera will never get stuck in an eternally rotating situation)
	if last_mouse_offset == mouse_offset: mouse_offset = Vector2.ZERO
