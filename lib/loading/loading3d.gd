extends Node3D

const smooth = 0.04
var ROCKET_PATH = "res://maps/sandbox/rocket.glb"

var mouse_pos
var center

var status
var loaded = false
var rocket
var progress = []

func _ready():
	mouse_pos = get_viewport().get_mouse_position()
	center = get_viewport().size / 2.0
	ResourceLoader.load_threaded_request(ROCKET_PATH)

func _process(_delta):
	status = ResourceLoader.load_threaded_get_status(ROCKET_PATH, progress)
	
	mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos == null or center == null: return
	
	var adj = Vector2(
		clamp(2.0 * mouse_pos.x / center.x - 1.0, -1.0, 1.0),
		clamp(2.0 * mouse_pos.y / center.y - 1.0, -1.0, 1.0))
	
	$Camera.position.x = lerp($Camera.position.x, 2.9 + adj.x * 0.6, smooth)
	$Camera.position.y = lerp($Camera.position.y, -1.23 + adj.y * 0.3, smooth)
	
	if rocket != null:
		rocket.rotation_degrees.y = lerp(
			rocket.rotation_degrees.y, adj.x * 2.0, smooth)

	if loaded == true: return
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		loaded = true
		var Rocket = ResourceLoader.load_threaded_get(ROCKET_PATH)
		rocket = Rocket.instantiate()
		rocket.position = Vector3(1.4, 0.0, -2.2)
		rocket.scale = Vector3(0.65, 0.65, 0.65)
		add_child(rocket)
