extends Node3D

const roll_extent = 20.0

@onready var trail_L = $Euclid/EuclidArmature/Skeleton3D/Wing_L/Wing_L/Trail3D
@onready var trail_R = $Euclid/EuclidArmature/Skeleton3D/Wing_R/Wing_R/Trail3D2

var anim_moving = false
var ry_delta = 0.0
var ry_last = 0.0
var radar_open = true

var root
var root_cam_pivot

var engine_ratio = 0.0 # sound
var expn = 1.10
var target_expn = 10.0

# Save references to glider mesh instances so we can change shader parameters
# on them via _set_shader_level(val)
var in_glide = false
var glider_nodes = []
#var glider_target_alpha = 0.0
var glider_alpha = 0.0

func _set_shader_level(val):
	glider_alpha = val
	for node in glider_nodes:
		node.get_active_material(0).set_shader_parameter("alpha_float", val)

func _set_shader_expn(get_expn):
	for node in glider_nodes:
		node.get_active_material(0).set_shader_parameter("exponent", get_expn)

func _glider_flicker_in():
	var t = create_tween().tween_method(_set_shader_level, 0.0, 0.5, 0.1)
	await t.finished
	t = create_tween().tween_method(_set_shader_level, 0.5, 0.0, 0.1)
	await t.finished
	t = create_tween().tween_method(_set_shader_level, 0.0, 0.5, 0.2)

func _glider_flicker_out():
	var t = create_tween().tween_method(_set_shader_level, 0.5, 0.0, 0.1)
	await t.finished
	t = create_tween().tween_method(_set_shader_level, 0.0, 0.5, 0.1)
	await t.finished
	t = create_tween().tween_method(_set_shader_level, 0.5, 0.0, 0.2)

func _glide_started():
	_glider_flicker_in()
	in_glide = true
	$GW/AnimationPlayer.play("ExtendWings")
	$GW/GW2/AnimationPlayer.play("ExtendWings")
	$GlideSound.play()

func _glide_ended():
	_glider_flicker_out()
	in_glide = false
	$GW/AnimationPlayer.play_backwards("ExtendWings")
	$GW/GW2/AnimationPlayer.play_backwards("ExtendWings")
	$GlideSound.stop()

func open_radar():
	radar_open = true
	$Radar.visible = true
	$Radar/AnimationPlayer.play("RadarKeyAction")

func close_radar():
	radar_open = false
	$Radar/AnimationPlayer.play_backwards("RadarKeyAction")
	await $Radar/AnimationPlayer.animation_finished
	if radar_open == false: # skip if player has gone back into an interact area
		$Radar.visible = false

func start_moving():
	engine_ratio = 1.0
	anim_moving = true
	$Euclid/AnimationTree["parameters/conditions/is_flying"] = true
	$Euclid/AnimationTree["parameters/conditions/not_flying"] = false
	$Stars.amount_ratio = 1.0

func stop_moving():
	engine_ratio = 0.0
	anim_moving = false
	$Euclid/AnimationTree["parameters/conditions/is_flying"] = false
	$Euclid/AnimationTree["parameters/conditions/not_flying"] = true
	$Stars.amount_ratio = 0.3

func _ready():
	root = get_parent()
	root_cam_pivot = root.get_node_or_null("CamPivot")
	for node in Utilities.get_all_children($GW):
		if node is MeshInstance3D:
			glider_nodes.append(node)
	
	Action.targeted.connect(open_radar)
	Action.untargeted.connect(close_radar)
	Global.insight_pane_closed.connect(stop_moving)
	
	# Debug visibility
	Global.debug_player_visibility_changed.connect(func():
		visible = Global.debug_player_visible)

func _stop_movement():
	if Action.in_glide == true: _glide_ended()
	Action.in_glide = false
	rotation.z = 0.0
	
	trail_L.enabled = false
	trail_R.enabled = false

func _process(_delta):
	if root == null: return
	if root.position_locked == true:
		_stop_movement()
		rotation_degrees.y = root.lock_dir.x
		return
	if !Global.can_move:
		_stop_movement()
		return
	
	$IdleSound.volume_db = linear_to_db(lerp(
		db_to_linear($IdleSound.volume_db), 1.0 - engine_ratio, 0.1))
	$RunSound.volume_db = linear_to_db(lerp(
		db_to_linear($RunSound.volume_db), engine_ratio, 0.1))
	
	if Action.in_glide == true:
		if in_glide == false: _glide_started()
	else: if in_glide == true: _glide_ended()
	
	if glider_alpha > 0.0:
		_set_shader_expn(expn)
		if $GW.visible == false:
			$GW.visible = true
	else:
		if $GW.visible == true:
			$GW.visible = false
	
	if trail_L.enabled == false: trail_L.reenable()
	if trail_R.enabled == false: trail_R.reenable()
	
	var roll_delta = 0.0
	ry_delta = 0.0
	
	if root.velocity.length() > 1.0:
		ry_delta = Utilities.short_angle_dist(
			root_cam_pivot.rotation.y, rotation.y) * -0.25
		ry_last = root_cam_pivot.rotation.y
	
	if Input.is_action_pressed("strafe_left"): roll_delta += 10.0
	if Input.is_action_pressed("strafe_right"): roll_delta -= 10.0
	
	# Slowly turns to match the camera
	rotation.y = lerp_angle(rotation.y, ry_last, 0.06)
	
	rotation.z = lerpf(
		rotation.z, ry_delta + roll_delta * 0.02, 0.06)
	rotation_degrees.z = clampf(
		rotation_degrees.z, -roll_extent, roll_extent)
	
	expn = lerp(expn, target_expn, 0.2)
	if expn > 9.95:
		target_expn = 1.0
		return
	if expn < 1.05:
		target_expn = 10.0
		return
