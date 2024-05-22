extends Node3D
# This script loads settings, music, and other things into the world.
# It should be extended after creating a new scene. NOTE: 'super()' MUST
# called from the inheriting script in order for everything to be loaded
# properly.

var tutorial_input_data = [
	{ "title": "INTERACT", "description": "Look at a nearby curiosity.", "key": "F" },
	{ "title": "GLIDE", "description": "Soar in updrafts; hover while descending.", "key": "E" } ]

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
var first_settings_run = false

func _setting_changed(get_setting_id):
	if first_settings_run == false: first_settings_run = true
	match get_setting_id:
		"fov": %Player/CamPivot/Camera.fov = Global.settings.fov
		"camera_sensitivity": %Player/CamPivot.camera_sensitivity = Global.settings.camera_sensitivity
		"volumetric_fog": %Sky.environment.volumetric_fog_enabled = Global.settings.volumetric_fog
		"bloom": %Sky.environment.glow_enabled = Global.settings.bloom

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
	if get_node_or_null("Insights") == null: return
	for i in %Insights.get_children().size():
		var n = %Insights.get_children()[i]
		if i == Global.insights_collected: n.visible = true
		else: n.visible = false

func proc_save():
	Save.load_from_file()
	insights_setup()

func _ready():
	# Reset everything so that ghost data doesn't persist after returning to the menu
	Action.deactivate() # interesting bug where an action will persist across maps
	Action.in_glide = false
	Global.insights_collected = 0

	# Fade in all sound if the game wasn't already muted
	Utilities.set_master_vol(0.0)
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings:
		if !setting == "volume": Global.setting_changed.emit(setting)
	
	Action.insight_advanced.connect(func():
		Global.insights_collected += 1
		insights_refresh())
	
	# ===== DATA TO SAVE =====
	Save.game_saved.connect(func():
		Save.set_data(map_name, "player_position", Global.player_ground_position)
		Save.set_data(map_name, "collected_insights", Global.insights_collected)
		Save.save_to_file())
	
	# ===== DATA TO LOAD =====
	Global.current_map = map_name
	Save.save_loaded.connect(func():
		var s_player_position = Save.get_data(Global.current_map, "player_position")
		if s_player_position != null: %Player.global_position = s_player_position
		var s_collected_insights = Save.get_data(Global.current_map, "collected_insights")
		if s_collected_insights != null: Global.insights_collected = s_collected_insights)
	
	if custom_data_load_signal == false: proc_save()
	
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
	if Save.get_data("dwelt", "tutorial_inputs_shown") == null:
		Global.input_hint_played.emit(tutorial_input_data, 5.0)
		Save.set_data("dwelt", "tutorial_inputs_shown", true)

func _notification(what):
	# Save the game on quit via Save.game_saved
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.printc("[WorldLoader] GAME QUIT NOTIFICATION RECEIVED.")
		Save.game_saved.emit()
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()
