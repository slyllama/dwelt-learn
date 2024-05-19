extends Node3D
# Load and display shaders in advance so that the game won't hang when a
# shader is used for the first time.

var shaders_loaded = false

const SHADERS = [
	"res://characters/euclid/radar/shader_radar.tres",
	"res://characters/euclid/shader_energy.tres",
	"res://characters/glider_wings/shader_glider.gdshader",
	"res://generic/shaders/shader_aberration.gdshader",
	"res://generic/shaders/shader_fractal.gdshader",
	"res://generic/shaders/shader_fresnel.gdshader",
	"res://generic/shaders/shader_glide.tres",
	"res://generic/shaders/shader_laser.tres",
	"res://lib/player/vfx/shader_anime.gdshader",
	"res://lib/ui/dialogue/shader_distort.gdshader",
	"res://lib/ui/insight/insight_flame/shader_flame.gdshader",
	"res://lib/ui/insight/shader_blur.gdshader",
	"res://lib/ui/insight/shader_ripple.gdshader",
	"res://lib/ui/smoke_overlay/shader_smoke.gdshader",
	"res://lib/ui/smoke_overlay/shader_smoke.tres",
	"res://objects/god_ray/shader_god_ray.tres",
	"res://objects/updraft/shader_whirl.gdshader",
	"res://objects/updraft/shader_whirl_center.tres"
]

var meshes = []

func _load_shaders():
	if shaders_loaded == false:
		shaders_loaded = true
		for mesh in meshes: mesh.queue_free()
		Global.shaders_loaded.emit()

func _ready():
	var i = 0
	for shader in SHADERS:
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
