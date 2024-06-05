extends Node3D
# This script loads settings, music, and other things into the world.
# It should be extended after creating a new scene. NOTE: 'super()' MUST
# called from the inheriting script in order for everything to be loaded
# properly.

const InsightProjectile = preload("res://objects/insight_projectile/insight_projectile.tscn")
const PingNodule = preload("res://lib/ui/ping_nodule/ping_nodule.tscn")
var tutorial_input_data = [
	{
		"title": "LOOK",
		"description": "Control the camera and cursor.", 
		"key": ["axis_action"]
	},
	{
		"title": "MOVE",
		"description": "Navigate the world.", 
		"key": ["strafe_right", "strafe_left", "move_back", "move_forward"]
	},
	{
		"title": "PING",
		"description": "Identify nearby curiosities and Insights.", 
		"key": ["skill_ping"]
	}]

@export var map_name = "untitled"
## Set this value to [code]true[/code] to allow the [code]WorldLoader[/code]'s
## extended script to handle custom save data before being processed.
## [code]Save.save_loaded()[/code] [b]must[/b] be called at the end of the
## extended script's [code]_ready()[/code] function if this option is set.
@export var custom_data_load_signal = false

# All lights in here will be excluded from spotlight shadows. Remember to add
# to this before calling super().
var exclude_from_shadow = []
# Static bodies included as children of the objects listed in
# 'spring_arm_objects' will have collision mask bit (2) set, and the player's
# spring arm will prevent the camera from clipping through them. Remember to
# add to this before calling super().
var spring_arm_objects = []
var interact_objects = []
var first_settings_run = false
var delay_passed = false # past first second of runtime?
var tutorial_hint_spawned = false # only for first run

var PingCooldown = Timer.new()
var PingSound = AudioStreamPlayer.new()
var ping_cooling = false

var initial_cam_rotation = Vector3.ZERO # in degrees

func _get_nearest_save_point(height = 2.0):
	if get_node_or_null("SavePoints") == null:
		Global.printc("[WorldLoader] no save point data!", "red")
	
	var nearest_point
	var closest_dist = 9999.99
	var s_player_position = Save.get_data(Global.current_map, "player_position")
	if !s_player_position:
		nearest_point = %SavePoints.get_node("Origin")
	else:
		for point in %SavePoints.get_children():
			# We always work from save points - if the player's position isn't saved,
			# we simply reckon from 0, 0
			var dist = Vector3(s_player_position).distance_to(point.global_position)
			if dist < closest_dist:
				closest_dist = dist
				nearest_point = point
	
	# Get the custom camera direction of the nearest save point, if it has one
	if "save_camera_rotation" in nearest_point:
		initial_cam_rotation = nearest_point.save_camera_rotation
		initial_cam_rotation.z = 0.0 # never shift the camera like this
	return(nearest_point.global_position + Vector3(0, height, 0))

func _setting_changed(get_setting_id):
	if first_settings_run == false: first_settings_run = true
	match get_setting_id:
		"fov": %Player/CamPivot/Camera.fov = Global.settings.fov
		"camera_sensitivity": %Player/CamPivot.camera_sensitivity = Global.settings.camera_sensitivity
		"volumetric_fog": %Sky.environment.volumetric_fog_enabled = Global.settings.volumetric_fog
		"bloom": %Sky.environment.glow_enabled = Global.settings.bloom
		"music_volume": if get_node_or_null("Music"):
			$Music.volume_db = linear_to_db(Global.settings.music_volume) * 0.8 # not so loud
		"vsync": if Global.settings.vsync: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# The following are only applied after the first run
	if first_settings_run == true:
		match get_setting_id:
			"full_screen": Utilities.toggle_full_screen()
			"volume": Utilities.set_master_vol(Global.settings.volume)
	Utilities.save_settings()

# Get the total number of insights
func insights_setup():
	Global.insights_total = 0
	if get_node_or_null("Insights") == null:
		Global.printc("[WorldLoader] no insights!")
		return
	for i in %Insights.get_children():
		Global.insights_total += 1
	Global.printc("[WorldLoader] found " + str(Global.insights_total) + " Insight(s).")
	Global.insights_counted.emit()
	insights_refresh()

# Display only the current insight, based on collected_insights
func insights_refresh():
	var insight_found = false
	
	if get_node_or_null("Insights") == null: return
	for i in %Insights.get_children().size():
		var n = %Insights.get_children()[i]
		if i == Global.insights_collected:
			n.visible = true
			insight_found = true
			Global.insight_current_position = n.global_position
			
		else: n.visible = false
	Global.insight_on_map = insight_found

func fire_ping():
	if ping_cooling or Action.active or Global.settings_opened: return
	
	ping_cooling = true
	PingCooldown.start()
	PingSound.play()
	Global.camera_shaken.emit(0.5)
	Input.start_joy_vibration(0, 0.05, 0.15, 0.09)
	
	# Process Insights, if there is one
	if Global.insight_on_map:
		insights_refresh()
		var inp = InsightProjectile.instantiate()
		add_child(inp)
		inp.global_position = Global.player_position
		inp.look_at(Global.insight_current_position)
		inp.fire()
	
	# Process nearby interactables
	for i in interact_objects:
		if Utilities.get_is_valid_interactable(i, 20.0):
			var nodule = PingNodule.instantiate()
			add_child(nodule)
			nodule.global_position = i.global_position

func proc_save():
	Save.load_from_file()
	insights_setup()

func _ready():
	PingSound.stream = load("res://lib/ui/ping_nodule/ping.ogg")
	add_child(PingSound)
	
	# Reset everything so that ghost data doesn't persist after returning to the menu
	Action.deactivate() # interesting bug where an action will persist across maps
	Action.in_glide = false
	Action.last_target = ""
	Global.insights_collected = 0
	Global.can_move = true
	Global.dialogue_closed_early.emit()

	# Fade in all sound if the game wasn't already muted
	Utilities.set_master_vol(0.0)
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings:
		if !setting == "volume": Global.setting_changed.emit(setting)
	
	Action.insight_advanced.connect(func():
		Global.insights_collected += 1
		insights_refresh())
	
	PingCooldown.set_wait_time(1.0)
	PingCooldown.one_shot = true
	PingCooldown.timeout.connect(func(): ping_cooling = false)
	add_child(PingCooldown)
	Global.ping.connect(fire_ping)
	
	# ===== DATA TO SAVE =====
	Save.game_saved.connect(func():
		Save.set_data(map_name, "player_position", Global.player_position)
		Save.set_data(map_name, "collected_insights", Global.insights_collected)
		Save.save_to_file())
	
	# ===== DATA TO LOAD =====
	Global.current_map = map_name
	Save.save_loaded.connect(func():
		%Player.global_position = _get_nearest_save_point()
		%Player.set_cam_rotation(initial_cam_rotation)
		var s_collected_insights = Save.get_data(Global.current_map, "collected_insights")
		if s_collected_insights: Global.insights_collected = s_collected_insights)
	
	if custom_data_load_signal == false: proc_save()
	insights_refresh()
	$HUD/DebugPane.update()
	
	# Set spring arm collisions
	var col_count = 0
	for o in spring_arm_objects:
		for n in Utilities.get_all_children(o):
			if n is StaticBody3D:
				col_count += 1
				n.set_collision_layer_value(2, true)
		if col_count > 0: Global.printc("[" + str(o)
			+ "] setting spring-arm collision mask for "
			+ str(col_count) + " object(s).")
	
	var fade_bus_in = create_tween()
	fade_bus_in.tween_method(Utilities.set_master_vol, 0.0, Global.settings.volume, 1.5)
	fade_bus_in.tween_callback(func(): Global.setting_changed.emit("volume"))
	
	await get_tree().create_timer(1.0).timeout
	delay_passed = true
	if !Save.get_data("dwelt", "tutorial_inputs_shown"):
		Global.input_hint_played.emit(tutorial_input_data, 0.0)
		tutorial_hint_spawned = true
		Save.set_data("dwelt", "tutorial_inputs_shown", true)
	if get_node_or_null("Music"): $Music.play()

func _input(_event):
	if Input.is_action_just_pressed("skill_ping"):
		fire_ping()
	# TODO: check this works on controller too
	if Input.is_action_just_pressed("move_forward"): # clear tutorials on movement
		if tutorial_hint_spawned:
			tutorial_hint_spawned = false
			Global.input_hint_cleared.emit()

func _notification(what):
	# Save the game on quit via Save.game_saved
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.printc("[WorldLoader] GAME QUIT NOTIFICATION RECEIVED.")
		Save.game_saved.emit()
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()
