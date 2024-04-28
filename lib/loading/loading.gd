extends CanvasLayer
# Loading screen

## If this option is set, opening the loading screen will automatically load
## the map specified in [code]debug_map[/code]. 
@export var debug_mode = false
@export var debug_map = "test_room"

var target_path: String
var status: int
var progress: Array[float] # ResourceLoader will put its status details here

func load_map(name):
	var path = "maps/" + str(name) + "/" + str(name) + ".tscn"
	print("Loading '" + path + "'")
	target_path = path
	ResourceLoader.load_threaded_request(target_path)

func _ready():
	# Set up for retina
	if DisplayServer.screen_get_size().x > 2000:
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(load("res://generic/tex/cursor_2x.png"))
	if debug_mode == true: load_map(debug_map)

func _process(_delta):
	if target_path == null or target_path == "": return
	status = ResourceLoader.load_threaded_get_status(target_path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$LoadBlack/ProgressBar.value = progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_path))
