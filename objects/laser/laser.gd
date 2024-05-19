extends Node3D
# NOTE: laser acts on collision group 2

@export var object_name = "laser"
@export var laser_move_speed = 0.3
@export var laser_limit_angle = Vector2(45.0, 30.0)

var delay_complete = false # laser won't start moving until after a short delay
var active = false

var og_cast_rotation_x
var og_cast_rotation_y

func activate():
	active = true
	Global.smoke_faded.emit("in")
	$EnterLaser.play()

	delay_complete = false
	Global.emit_signal(
		"player_position_locked",
		$DockingPoint.global_position,
		Vector2(rotation_degrees.y, 0.0))
	
	await get_tree().create_timer(0.7).timeout
	delay_complete = true

func deactivate():
	active = false
	Global.smoke_faded.emit("in")
	Global.player_position_unlocked.emit()

func _ready():
	# Object handler-specifics
	$ObjectHandler.object_name = object_name
	$ObjectHandler.activated.connect(activate)
	$ObjectHandler.deactivated.connect(deactivate)
	
	# For measuring and checking limits
	og_cast_rotation_x = $Cast.rotation_degrees.x
	og_cast_rotation_y = $Cast.rotation_degrees.y
	
	$Cable.visible = true
	$Cable.end = $Cast.global_position
	$Cable.update()

var start = 2

func _process(_delta):
	if $Cast.is_colliding() == true:
		$Cable.start = lerp($Cable.start, $Cast.get_collision_point(), 0.5)
		$Cable.toggle_end_point(true)
	else:
		$Cable.start = lerp($Cable.start, $Cast/EndPoint.global_position, 0.5)
		$Cable.toggle_end_point(false)
	
	# Allow to update for 2 frames, and then only run after the delay
	if start > 0: start -= 1
	else: if delay_complete == false: return
	
	# Also prevents camera movement on controller from moving the laser
	# TODO: joy axis check in Utilities so you can use player movement to control the laser instead
	if active == false: return
	if Input.is_action_pressed("ui_up") and !Input.get_joy_axis(0, JOY_AXIS_LEFT_Y):
		$Cast.rotation_degrees.x += laser_move_speed
	if Input.is_action_pressed("ui_down") and !Input.get_joy_axis(0, JOY_AXIS_LEFT_Y):
		$Cast.rotation_degrees.x -= laser_move_speed
	if Input.is_action_pressed("ui_left") and !Input.get_joy_axis(0, JOY_AXIS_LEFT_X):
		$Cast.rotation_degrees.y += laser_move_speed
	if Input.is_action_pressed("ui_right") and !Input.get_joy_axis(0, JOY_AXIS_LEFT_X):
		$Cast.rotation_degrees.y -= laser_move_speed

	# Apply limits
	$Cast.rotation_degrees.x = clamp(
		$Cast.rotation_degrees.x,
		og_cast_rotation_x - laser_limit_angle.y,
		og_cast_rotation_x + laser_limit_angle.y)
	$Cast.rotation_degrees.y = clamp(
		$Cast.rotation_degrees.y,
		og_cast_rotation_y - laser_limit_angle.x,
		og_cast_rotation_y + laser_limit_angle.x)
	
	if $Cast.cast_is_on_type() == true:
		$Cast.get_collider().set_active($Cast)
