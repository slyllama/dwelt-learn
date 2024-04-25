extends Node3D
# NOTE: laser acts on collision group 2

@export var TYPE = "laser"
@export var laser_move_speed = 0.5
@export var laser_limit_angle = Vector2(45.0, 10.0)

var overlay_texture = Sprite2D.new()
var delay_complete = false # laser won't start moving until after a short delay
var active = false

func activate():
	active = true
	overlay_texture.visible = true
	overlay_texture.scale = Vector2(1.0, 1.0)
	overlay_texture.rotation_degrees = 45.0
	
	delay_complete = false
	var fade_tween = create_tween()
	fade_tween.tween_property(overlay_texture, "modulate:a", 1.0, 0.3)
	Global.emit_signal(
		"player_position_locked",
		$DockingPoint.global_position,
		Vector2(global_rotation_degrees.y, 0.0), 40.0, 20.0)
	
	await get_tree().create_timer(0.7).timeout
	delay_complete = true

func deactivate():
	active = false
	var fade_tween = create_tween()
	fade_tween.tween_property(overlay_texture, "modulate:a", 0.0, 0.1)
	fade_tween.tween_callback(func():
		if active == true: return
		overlay_texture.visible = false)
	Global.player_position_unlocked.emit()
	Global.interact_entered.emit()

func _ready():
	$InteractArea.TYPE = TYPE
	$InteractArea.activated.connect(activate)
	$InteractArea.deactivated.connect(deactivate)
	
	$Cable.visible = true
	$Cable.end = $Cast.global_position
	$Cable.update()
	
	overlay_texture.texture = load("uid://d3xxoqd47y644")
	overlay_texture.position = Vector2(1920.0, 1080.0) / 2.0
	add_child(overlay_texture)
	overlay_texture.modulate.a = 0.0

var start = 2

func _process(_delta):
	overlay_texture.scale = lerp(overlay_texture.scale, Vector2(0.7, 0.7), 0.2)
	overlay_texture.rotation_degrees = lerp(overlay_texture.rotation_degrees, 0.0, 0.2)
	
	if $Cast.is_colliding() == true:
		$Cable.start = lerp($Cable.start, $Cast.get_collision_point(), 0.5)
		$Cable.toggle_end_point(true)
	else:
		$Cable.start = lerp($Cable.start, $Cast/EndPoint.global_position, 0.5)
		$Cable.toggle_end_point(false)
	
	# Allow to update for 2 frames, and then only run after the delay
	if start > 0: start -= 1
	else: if delay_complete == false: return
	
	if $InteractArea.active == false: return
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
		-laser_limit_angle.y,
		laser_limit_angle.y)
	$Cast.rotation_degrees.y = clampf(
		$Cast.rotation_degrees.y,
		-laser_limit_angle.x,
		laser_limit_angle.x)
	
	if $Cast.cast_is_on_type() == true:
		$Cast.get_collider().set_active($Cast)
