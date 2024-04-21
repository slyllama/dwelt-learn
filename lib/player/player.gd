extends CharacterBody3D

# Try this: https://forum.godotengine.org/t/how-to-program-the-ability-to-jump-in-4-0-2-in-3d/1997/2

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
var raycast_y_point = 0.0
var over_area = false

# Thanks https://forum.godotengine.org/t/lerping-a-2d-angle-while-going-trought-the-shortest-possible-distance/24124/2
func _short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func _fstr(num, place = 0.01):  return(str(snapped(num, place)))

func update_debug():

	Global.debug_details_text = ("position = ("
		+ _fstr(global_position.x) + ", "
		+ _fstr(global_position.y) + ", "
		+ _fstr(global_position.z) + ")")
	Global.debug_details_text += "\nmagnitude = " + _fstr(velocity.length())
	Global.debug_details_text += "\ndirection = " + _fstr($CamPivot.rotation_degrees.y, 1)
	Global.debug_details_text += "\u00B0 (" + str(snapped($PlaceholderMesh.rotation_degrees.y, 1))  + "\u00B0)"
	Global.debug_details_text += "\nraycast_y_point = " + str(snapped(raycast_y_point, 0.01))

func _ready():
	# Set up for retina
	if DisplayServer.screen_get_size().x > 2000:
#		get_window().size = get_window().size * 1.5
#		get_window().position -= Vector2i(get_window().size.x / 4.0, get_window().size.y / 4.0)
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(load("res://generic/tex/cursor_2x.png"))

func _input(_event):
	if Global.in_keybind_select == true: return
	
	if Input.is_action_just_pressed("move_forward"):
		$Stars.amount_ratio = 1.0
		$SoundHandler.move()
		$PlaceholderMesh/AnimationPlayer.play("Fly")
	if Input.is_action_just_released("move_forward"):
		$Stars.amount_ratio = 0.3
		$SoundHandler.stop_moving()
		$PlaceholderMesh/AnimationPlayer.play_backwards("Fly")
	
	if Input.is_action_just_pressed("move_back"):
		$Stars.amount_ratio = 1.0
		$SoundHandler.move()
		$PlaceholderMesh/AnimationPlayer.play("Fly")
	if Input.is_action_just_released("move_back"):
		$Stars.amount_ratio = 0.3
		$SoundHandler.stop_moving()
		$PlaceholderMesh/AnimationPlayer.play_backwards("Fly")

func _physics_process(_delta):
	forward = 0
	side = 0
	rotation_diff = 0.0
	var strafe_diff = 0.0
	
	if Global.in_keybind_select == true: return
	
	if Input.is_action_pressed("move_forward"): forward += 1
	if Input.is_action_pressed("move_back"): forward -= 1
	if Input.is_action_pressed("strafe_left"):
		strafe_diff += 10.0
		side += 0.5
	if Input.is_action_pressed("strafe_right"):
		strafe_diff -= 10.0
		side -= 0.5
	
	target_velocity = (-forward * $CamPivot.global_transform.basis.z
		+ -side * $CamPivot.global_transform.basis.x)
	target_velocity = target_velocity.normalized() * Vector3(1, 0, 1) * speed # strip out the camera looking up/down
	
	velocity = lerp(velocity, target_velocity, speed_smoothing)
	move_and_slide()

	if velocity.length() > 0.1:
		#rotation_diff = ($CamPivot.rotation.y - $PlaceholderMesh.rotation.y) * 0.25
		rotation_diff = _short_angle_dist($CamPivot.rotation.y, $PlaceholderMesh.rotation.y) * -0.25
		last_pivot_y_rotation = $CamPivot.rotation.y
	
	# Robot slowly turns to match the camera
	$PlaceholderMesh.rotation.y = lerp_angle(
		$PlaceholderMesh.rotation.y, last_pivot_y_rotation, 0.06)
	
	# Robot yaws to match rotation rate and strafe
	$PlaceholderMesh.rotation.z = lerpf(
		$PlaceholderMesh.rotation.z, rotation_diff + strafe_diff * 0.02, 0.06)
	$PlaceholderMesh.rotation_degrees.z = clampf(
		$PlaceholderMesh.rotation_degrees.z, -model_yaw_extent, model_yaw_extent)

	# Raycast stuff - this will need to go into a new section
	if $YCast.get_collider() != null:
		raycast_y_point = $YCast.get_collision_point().y
	
	position.y = lerp(position.y, raycast_y_point + hover_height, 0.07)
	Global.player_position = position
	
	update_debug()
	
	if $YCast.get_collider() != null:
		if "TYPE" in $YCast.get_collider():
			if $YCast.get_collider().TYPE == "ignore": return
			if over_area == false:
				Global.emit_signal("interact_entered")
				over_area = true
				Global.in_area_name = $YCast.get_collider().TYPE
			Global.debug_details_text += ("\n[color=yellow]Over: '"
				+ str($YCast.get_collider().TYPE) + "'[/color]")
		else:
			if over_area == true:
				Global.emit_signal("interact_left")
				over_area = false
				Global.in_area_name = ""
