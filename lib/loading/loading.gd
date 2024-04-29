extends CanvasLayer
# Loading screen

var target_path: String
var status: int
var progress: Array[float] # ResourceLoader will put its status details here

func _make_path(map_name):
	return("maps/" + str(map_name) + "/" + str(map_name) + ".tscn")

func load_map(map_name):
	if !FileAccess.file_exists(_make_path(map_name)):
		$ErrorText.text = Utilities.cntr("Error: couldn't load map '" + map_name + "'.")
		$ErrorText.visible = true
		return
	
	$LoadBlack/ProgressBar.visible = true
	$GlowIcon.visible = true
	$LoadPanel.visible = false
	var path = _make_path(map_name)
	print("Loading '" + path + "'.")
	target_path = path
	ResourceLoader.load_threaded_request(target_path)

func _ready():
	# Set up for retina
	if DisplayServer.screen_get_size().x > 2000:
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(
				load("res://generic/tex/cursor_2x.png"))
	Utilities.load_settings()
	$LoadBlack/ProgressBar.visible = false
	$GlowIcon.visible = false
	$LoadPanel/VBox/TestRoomButton.grab_focus()

func _process(_delta):
	if target_path == null or target_path == "": return
	status = ResourceLoader.load_threaded_get_status(target_path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			## progress[0] seems to cap at 0.5, hence the multiplier (and the
			## clamp in case it ever, y'know, doesn't)
			#$LoadBlack/ProgressBar.value = clampf(
				#progress[0] * 2.0 * 100, 0, 100)
			$LoadBlack/ProgressBar.value = lerp($LoadBlack/ProgressBar.value, progress[0] * 100.0, 0.1)
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(
				ResourceLoader.load_threaded_get(target_path))

func _map_button_pressed(map_name = ""):
	load_map(map_name)
