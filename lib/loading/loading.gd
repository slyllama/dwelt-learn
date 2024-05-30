extends CanvasLayer
# Loading screen

var target_path: String
var status: int
var progress: Array[float] # ResourceLoader will put its status details here
var started = false
var target_mus_vol = 0.7

var settings_last_button # focus will be given back to this button

func _make_path(map_name):
	return("res://maps/" + str(map_name) + "/" + str(map_name) + ".tscn")

func _setting_changed(get_setting_id):
	match get_setting_id:
		"volume": Utilities.set_master_vol(Global.settings.volume)
		"full_screen": Utilities.toggle_full_screen()
	Utilities.save_settings()

func load_map(map_name):
	if !FileAccess.file_exists(_make_path(map_name)):
		$ErrorText.text = Utilities.cntr("[Load] error: couldn't load map '" + map_name + "'.")
		$ErrorText.visible = true
		return
	started = true
	get_parent().cam_x_offset = -6.0
	get_parent().cam_z_offset = 16.0
	var fade_tween = create_tween()
	fade_tween.tween_property($LoadBlack, "color", Color.BLACK, 1.0)
	var fov_tween = create_tween()
	fov_tween.tween_method(func(i):
		get_parent().get_node("Camera").fov = i, 55.0, 45.0, 1.0)

	$LoadBlack/ProgressBar.visible = true
	$GlowIcon.visible = true
	$LoadPanel.visible = false
	var path = _make_path(map_name)
	Global.printc("[Load] loading '" + path + "'.")
	target_path = path
	ResourceLoader.load_threaded_request(target_path)

func _ready():
	for _i in 20: Global.printc("\n", "white", true) # prime the debug buffer!
	Global.current_map = ""
	Global.printc("--- This is Dwelt (Technical Test) ---", "cyan")
	
	$HUDButtons.settings_pressed.connect(func():
		Global.button_click.emit()
		settings_last_button = $HUDButtons/TopMenu/SettingsButton
		$Settings.open()
		return)
	
	# Load and populate settings (including menu)
	Utilities.load_settings()
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings:
		Global.setting_changed.emit(setting)
	
	Global.debug_toggled.emit() # make the toolbar button reappear
	$DebugPane.update()
	
	# Set up for retina
	Utilities.configure_screen()
	
	# First-run controller check
	$InputTools.check_for_controller()
	
	# Focus assignments
	$LoadPanel/VBox/Quit.focus_neighbor_bottom = "../../../HUDButtons/TopMenu/SettingsButton"
	$HUDButtons/TopMenu/SettingsButton.focus_neighbor_top = "../../../LoadPanel/VBox/Quit"
	$HUDButtons/TopMenu/DebugPopupButton.focus_neighbor_top = "../../../LoadPanel/VBox/Quit"
	Global.debug_toggled.connect(func():
		if !Global.debug_state: $HUDButtons/TopMenu/SettingsButton.grab_focus())

	$Settings/Control/Panel/VBox/MapSelection.visible = false # no need to go to the menu from the menu
	$LoadBlack/ProgressBar.visible = false
	$GlowIcon.visible = false
	$LoadPanel/VBox/Play.grab_focus()
	
	# Regain focus on the correct settings button after it is closed, for controllers
	$Settings/Control/Panel/InputVBox/LowerCloseButton.pressed.connect(
		func(): settings_last_button.grab_focus())

	$Music.volume_db = linear_to_db(target_mus_vol)
	if !get_parent().disable_music:
		await get_tree().create_timer(0.5).timeout
		$Music.play()

func _input(_event):
	if Input.is_action_just_pressed("debug_action"): load_map("test")

func _process(_delta):
	if started == true: target_mus_vol = lerp(target_mus_vol, 0.0, 0.1)
	$Music.volume_db = linear_to_db(target_mus_vol)

	status = ResourceLoader.load_threaded_get_status(target_path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$LoadBlack/ProgressBar.value = lerp(
				$LoadBlack/ProgressBar.value, progress[0] * 100.0, 0.1)
		ResourceLoader.THREAD_LOAD_LOADED:
			Utilities.set_master_vol(0.0) # prevent one frame of full volume!
			get_tree().change_scene_to_packed(
				ResourceLoader.load_threaded_get(target_path))

func _map_button_pressed(map_name = ""):
	Global.button_click.emit()
	if map_name == "quit":
		get_tree().quit()
		return
	elif map_name == "settings":
		$Settings.open()
		settings_last_button = $LoadPanel/VBox/Settings
		return
	load_map(map_name)

func _hover(): Global.button_hover.emit()

func _on_debug_popup_button_pressed():
	if !Global.debug_state: # show the debug pane if it already isn't visible
		Global.debug_state = true
		Global.debug_toggled.emit()
	if Global.debug_popup_is_open: Global.debug_popup_closed.emit()
	else: Global.debug_popup_opened.emit()
