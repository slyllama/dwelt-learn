extends Node3D
# Load and display shaders in advance so that the game won't hang when a
# shader is used for the first time.

## Time to hold before clearing meshes and signalling that the shaders have
## been loaded
@export var wait_time = 1.0

const SHADERS_UID = [
	"uid://cupub7pghtysj", # holograph
	"uid://dsggukocef5lg", # propulsion cone
	"uid://yi627x8xvfu2", # laser
	"uid://dtg3t52t3kle7", # god ray
	"uid://dg1bo2f0gnaue", # Kryptis
	
	"res://generic/shaders/fresnel.gdshader", # fresnel
	"res://lib/ui/dialogue/dialogue.gdshader", # dialogue (static)
	"res://lib/ui/dialogue/radial_distort.gdshader", # radial distortion
	"res://lib/ui/hud/intro_vfx.gdshader" # intro VFX
]

var meshes = []

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
	
	await get_tree().create_timer(wait_time).timeout
	for mesh in meshes: mesh.queue_free()
	Global.shaders_loaded.emit()
