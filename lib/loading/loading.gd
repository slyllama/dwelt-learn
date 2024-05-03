extends CanvasLayer
# Loading screen

var target_path: String
var status: int
var progress: Array[float] # ResourceLoader will put its status details here
var started = false

func _make_path(map_name):
	return("res://maps/" + str(map_name) + "/" + str(map_name) + ".tscn")

func _setting_changed(get_setting_id):
	match get_setting_id:
		"volume": AudioServer.set_bus_volume_db(0, linear_to_db(Global.settings.volume))
		"full_screen": Utilities.toggle_full_screen()
		"larger_ui":
			if Global.settings.larger_ui == true:
				get_window().content_scale_factor = Global.LARGE_UI_SCALE
			else: get_window().content_scale_factor = 1.0
	Utilities.save_settings()

func load_map(map_name):
	if !FileAccess.file_exists(_make_path(map_name)):
		$ErrorText.text = Utilities.cntr("Error: couldn't load map '" + map_name + "'.")
		$ErrorText.visible = true
		return
	started = true

	$LoadBlack/ProgressBar.visible = true
	$GlowIcon.visible = true
	$LoadPanel.visible = false
	var path = _make_path(map_name)
	print("Loading '" + path + "'.")
	target_path = path
	ResourceLoader.load_threaded_request(target_path)

func _ready():
	# Load and populate settings (including menu)
	Utilities.load_settings()
	Global.setting_changed.connect(_setting_changed)
	for setting in Global.settings: Global.setting_changed.emit(setting)
	AudioServer.set_bus_volume_db(0, linear_to_db(Global.settings.volume))

	# Set up for retina
	if DisplayServer.screen_get_size().x > 2000:
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(
				load("res://lib/ui/tex/cursor_2x.png"))
	
	$LoadBlack/ProgressBar.visible = false
	$GlowIcon.visible = false
	$LoadPanel/VBox/ScrapperButton.grab_focus()

func _process(_delta):
	if target_path == null or target_path == "": return

	status = ResourceLoader.load_threaded_get_status(target_path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$LoadBlack/ProgressBar.value = lerp(
				$LoadBlack/ProgressBar.value, progress[0] * 100.0, 0.1)
		ResourceLoader.THREAD_LOAD_LOADED:
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
