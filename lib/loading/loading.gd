extends CanvasLayer
# Loading screen

var target_path: String
var status: int
var progress: Array[float] # ResourceLoader will put its status details here
var started = false
var target_mus_vol = 0.7

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

	$LoadBlack/ProgressBar.visible = true
	$GlowIcon.visible = true
	$LoadPanel.visible = false
	var path = _make_path(map_name)
	Global.printc("[Load] loading '" + path + "'.")
	target_path = path
	ResourceLoader.load_threaded_request(target_path)

func _ready():
	for _i in 20: Global.printc("\n", "white", true) # prime the debug buffer!
	
	# Load and populate settings (including menu)
	Utilities.load_settings()
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings:
		Global.setting_changed.emit(setting)
	
	# Set up for retina
	if DisplayServer.screen_get_size().x > 2000:
		DisplayServer.window_set_min_size(Global.MIN_SCREEN_SIZE * 2.0)
		get_window().content_scale_factor = 2.0
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(
				load("res://lib/ui/tex/cursor_2x.png"))
	else: DisplayServer.window_set_min_size(Global.MIN_SCREEN_SIZE)
	
	$Settings/Control/Panel/VBox/MapSelection.visible = false # no need to go to the menu from the menu
	$LoadBlack/ProgressBar.visible = false
	$GlowIcon.visible = false
	$LoadPanel/VBox/Play.grab_focus()
	
	# Regain focus on the settings button after it is closed, for controllers
	$Settings/Control/Panel/InputVBox/LowerCloseButton.pressed.connect(
		func(): $LoadPanel/VBox/Settings.grab_focus())
	
	if Global.debug_state: $FPSCounter.visible = true
	
	$Music.volume_db = linear_to_db(target_mus_vol)
	await get_tree().create_timer(0.5).timeout
	$Music.play()

func _input(_event):
	if Input.is_action_just_pressed("debug_action"):
		load_map("test")
	if Input.is_action_just_pressed("toggle_debug"):
		$FPSCounter.visible = !$FPSCounter.visible
		Global.debug_state = $FPSCounter.visible # debug will retain its state

func _process(_delta):
	if started == true: target_mus_vol = lerp(target_mus_vol, 0.0, 0.1)
	$Music.volume_db = linear_to_db(target_mus_vol)
	#if target_mus_vol <= 0.1: Utilities.set_master_vol(0.0)
	
	var colour = "green"
	if Engine.get_frames_per_second() < 20.0: colour = "red"
	$FPSCounter.text = ("[right][color=" + colour + "]"
		+ str(Engine.get_frames_per_second()) + "fps[/color][/right]")
	
	if target_path == null or target_path == "": return
	
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
		return
	load_map(map_name)

func _hover(): Global.button_hover.emit()
