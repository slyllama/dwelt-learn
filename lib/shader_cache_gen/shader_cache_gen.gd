extends Node3D
# Load and display shaders in advance so that the game won't hang when a
# shader is used for the first time.

var shaders_loaded = false
var meshes = []

func _load_shaders():
	if shaders_loaded == false:
		shaders_loaded = true
		for mesh in meshes: mesh.queue_free()
		Global.shaders_loaded.emit()

func _ready():
	var i = 0
	
	var shaders_file = FileAccess.open("res://shader_list.txt", FileAccess.READ)
	var shaders_list = shaders_file.get_as_text().replace("\n", "").replace("\r", "").split(",")
	shaders_file.close()
	
	for shader in shaders_list:
		#Global.printc("[ShaderCacheGen] compiling shader " + str(shader) + "...", "gray")
		var shader_mesh = CSGBox3D.new()
		shader_mesh.size = Vector3(0.1, 0.1, 0.1)
		shader_mesh.position = Vector3(0.11 * i, 0.0, 0.0)
		shader_mesh.material = ShaderMaterial.new()
		shader_mesh.material.set_shader(load(shader))
		meshes.append(shader_mesh)
		add_child(shader_mesh)
		i += 1
	Global.printc("[ShaderCacheGen] finished compiling " + str(i) + " shader(s).")

var frame = 0
func _process(_delta):
	if frame == 5: _load_shaders()
	if frame <= 6: frame += 1
