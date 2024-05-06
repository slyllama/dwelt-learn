extends Node3D
# Load and display shaders in advance so that the game won't hang when a
# shader is used for the first time.

var shaders_loaded = false

const SHADERS_UID = [
	"uid://cupub7pghtysj", # holograph
	"uid://dsggukocef5lg", # propulsion cone
	"uid://yi627x8xvfu2", # laser
	"uid://dtg3t52t3kle7", # god ray
	"uid://dib8bbgu76bfe", # smoke
	"uid://x7hijf0o02h8", # updraft whirl
	"uid://dlmkx7n01hlq6", # updraft whirl center
	
	"res://generic/shaders/fresnel.gdshader", # fresnel
	"res://lib/ui/dialogue/dialogue.gdshader", # dialogue (static)
	"res://lib/ui/dialogue/radial_distort.gdshader", # radial distortion
	"res://lib/player/anime_wobble.gdshader", # anime motion
	"res://generic/shaders/aberration.gdshader" # chromatic aberration
]

var meshes = []

func _load_shaders():
	if shaders_loaded == false:
		shaders_loaded = true
		for mesh in meshes: mesh.queue_free()
		Global.shaders_loaded.emit()

func _ready():
	var i = 0
	for shader in SHADERS_UID:
		var shader_mesh = CSGBox3D.new()
		shader_mesh.size = Vector3(0.1, 0.1, 0.1)
		shader_mesh.position = Vector3(0.11 * i, 0.0, 0.0)
		shader_mesh.material = ShaderMaterial.new()
		shader_mesh.material.set_shader(load(shader))
		meshes.append(shader_mesh)
		add_child(shader_mesh)
		i += 1

var frame = 0
func _process(_delta):
	if frame == 5: _load_shaders()
	if frame <= 6: frame += 1
