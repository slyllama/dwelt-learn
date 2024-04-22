extends Area3D
# NOTE: the laser operates on collision group 2 -- meshes will need to be set
# to reflect this.
# TODO: make a generic area class

@export var TYPE = "laser"
## The movement speed of the laser controls.
@export var laser_move_speed = 0.5
## Specifies the initial rotation of the camera when the laser is activated, relative to the orientation of the laser itself.
@export var pointing_at = Vector2(90.0, 10.0)
## Limits how far (in degrees) the laser may be moved from its original orientation.
@export var laser_limit_angle = 20.0

var active = false
var in_area = false

func _ready():
	$Cable.end = $Cast.global_position
	$Cable.update()

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		if in_area == false: return
		if active == false:
			active = true
			$Cable.set_active(true)
			Global.emit_signal(
				"player_position_locked",
				$DockingPoint.global_position,
				pointing_at, 40.0, 20.0)
			return
		else:
			$Cable.set_active(false)
			active = false
			Global.interact_left.emit() # hide overlay on leaving
			Global.player_position_unlocked.emit()
			return

func _process(_delta):
	if Global.in_area_name != TYPE: 
		if in_area == true:
			in_area = false
			return
	else: if in_area == false:
		in_area = true
	
	if $Cast.is_colliding() == true:
		$Cable.start = lerp($Cable.start, $Cast.get_collision_point(), 0.5)
		$Cable.toggle_end_point(true)
	else:
		$Cable.start = lerp($Cable.start, $Cast/EndPoint.global_position, 0.5)
		$Cable.toggle_end_point(false)
	
	if active == false: return
	if Input.is_action_pressed("move_forward"):
		$Cast.rotation_degrees.x += laser_move_speed
	if Input.is_action_pressed("move_back"):
		$Cast.rotation_degrees.x -= laser_move_speed
	if Input.is_action_pressed("strafe_left"):
		$Cast.rotation_degrees.y += laser_move_speed
	if Input.is_action_pressed("strafe_right"):
		$Cast.rotation_degrees.y -= laser_move_speed
	
	# Limit the rotation of the laser
	$Cast.rotation_degrees.x = clampf(
		$Cast.rotation_degrees.x,
		pointing_at.y - laser_limit_angle, pointing_at.y + laser_limit_angle)
	$Cast.rotation_degrees.y = clampf(
		$Cast.rotation_degrees.y,
		pointing_at.x - laser_limit_angle, pointing_at.x + laser_limit_angle)
