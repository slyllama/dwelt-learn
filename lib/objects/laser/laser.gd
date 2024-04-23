extends Node3D
# NOTE: the laser operates on collision group 2 -- meshes will need to be set
# to reflect this.
# TODO: make a generic area class

@export var TYPE = "laser"
## The movement speed of the laser controls.
@export var laser_move_speed = 0.5
## Specifies the initial rotation of the camera when the laser is activated,
## relative to the orientation of the laser itself.
@export var pointing_at = Vector2(90.0, 10.0)
## Limits how far (in degrees) the laser may be moved from its original
## orientation.
@export var laser_limit_angle = 20.0

var overlay_texture = Sprite2D.new()

func activate():
	overlay_texture.scale = Vector2(1.0, 1.0)
	overlay_texture.rotation_degrees = 45.0
	var fade_tween = create_tween()
	fade_tween.tween_property(overlay_texture, "modulate:a", 1.0, 0.3)
	Global.emit_signal(
		"player_position_locked",
		$DockingPoint.global_position,
		pointing_at, 40.0, 20.0)

func deactivate():
	var fade_tween = create_tween()
	fade_tween.tween_property(overlay_texture, "modulate:a", 0.0, 0.1)
	Global.player_position_unlocked.emit()

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

#func _input(_event):
	#if Input.is_action_just_pressed("interact"):
		#if (in_area == false or Global.in_action == true): return
		#if active == false:
			#overlay_texture.scale = Vector2(1.0, 1.0)
			#overlay_texture.rotation_degrees = 45.0
			#var fade_tween = create_tween()
			#fade_tween.tween_property(overlay_texture, "modulate:a", 1.0, 0.3)
			#active = true
			#Global.interact_left.emit() # hide overlay
			#Global.emit_signal(
				#"player_position_locked",
				#$DockingPoint.global_position,
				#pointing_at, 40.0, 20.0)
			#return
		#else:
			#active = false
			#var fade_tween = create_tween()
			#fade_tween.tween_property(overlay_texture, "modulate:a", 0.0, 0.1)
			#Global.player_position_unlocked.emit()
			#return

func _process(_delta):
	#if Global.in_area_name != TYPE: 
		#if in_area == true:
			#in_area = false
			#return
	#else: if in_area == false:
		#in_area = true
	
	overlay_texture.scale = lerp(overlay_texture.scale, Vector2(0.7, 0.7), 0.2)
	overlay_texture.rotation_degrees = lerp(overlay_texture.rotation_degrees, 0.0, 0.2)
	
	if $Cast.is_colliding() == true:
		$Cable.start = lerp($Cable.start, $Cast.get_collision_point(), 0.5)
		$Cable.toggle_end_point(true)
	else:
		$Cable.start = lerp($Cable.start, $Cast/EndPoint.global_position, 0.5)
		$Cable.toggle_end_point(false)
	
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
		pointing_at.y - laser_limit_angle, pointing_at.y + laser_limit_angle)
	$Cast.rotation_degrees.y = clampf(
		$Cast.rotation_degrees.y,
		pointing_at.x - laser_limit_angle, pointing_at.x + laser_limit_angle)
	
	if $Cast.cast_is_on_type() == true:
		$Cast.get_collider().set_active($Cast)
