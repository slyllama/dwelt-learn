extends Node3D
# 3D wrapper for the loading screen. This renders the rocket in the background
# But doesn't do any actual loading work -- see `loading.gd` for that stuff.

const smooth = 0.04
var ROCKET_PATH = "res://objects/rocket/rocket.glb"

@export var disable_music = false

var mouse_pos
var center
var cam_x_offset = 0.0
var cam_z_offset = 0.0
var focus_y_offset = 0.0

var status
var loaded = false
var rocket
var progress = []

func _ready():
	cam_z_offset = $Camera.position.z
	mouse_pos = get_viewport().get_mouse_position()
	center = get_viewport().size
	ResourceLoader.load_threaded_request(ROCKET_PATH)
	
	$CanvasLoadOverlay.visible = true
	$CanvasLoadOverlay/BG/Flicker.play("flicker")

func _process(_delta):
	status = ResourceLoader.load_threaded_get_status(ROCKET_PATH, progress)
	
	mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos == null or center == null: return
	
	var adj = Vector2(
		clamp(2.0 * mouse_pos.x / center.x - 1.0, -1.0, 1.0),
		clamp(2.0 * mouse_pos.y / center.y - 1.0, -1.0, 1.0))
	
	$Camera.position.x = lerp($Camera.position.x, 2.5 + adj.x * 0.6 + cam_x_offset, smooth)
	$Camera.position.y = lerp($Camera.position.y, -1.23 + adj.y * 0.3 + focus_y_offset, smooth)
	$Camera.position.z = lerp($Camera.position.z, cam_z_offset, smooth)
	
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
		
		var fade_tween = create_tween()
		fade_tween.tween_property($ModelLoadOverlay/BG, "modulate:a", 0.0, 1.0)
		fade_tween.tween_callback(func(): $ModelLoadOverlay/BG.visible = false)

# Subtle effect for controllers
func _on_play_focus_entered(): focus_y_offset = 0.0
func _on_settings_focus_entered(): focus_y_offset = -0.3
func _on_quit_focus_entered(): focus_y_offset = -0.6
