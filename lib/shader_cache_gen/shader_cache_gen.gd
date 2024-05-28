extends Node3D
# Load and display shaders in advance so that the game won't hang when a
# shader is used for the first time.

var shaders_loaded = false
var meshes = []
var rects = []

func _load_shaders():
	if shaders_loaded == false:
		shaders_loaded = true
		for mesh in meshes: mesh.queue_free()
		for rect in rects: rect.queue_free()
		Global.shaders_loaded.emit()
		
		queue_free()

func _ready():
	var sp_count = 0
	var sc_count = 0
	
	var shaders_file = FileAccess.open("res://shader_list.txt", FileAccess.READ)
	var shaders_list = shaders_file.get_as_text().replace("\n", "").replace("\r", "").split(",")
	shaders_file.close()
	
	for shader in shaders_list:
		if "sp_" in shader:
			sp_count += 1
			var shader_mesh = CSGBox3D.new()
			shader_mesh.size = Vector3(0.1, 0.1, 0.1)
			shader_mesh.position = Vector3(0.11 * sp_count, 0.0, -5.0)
			shader_mesh.material = ShaderMaterial.new()
			shader_mesh.material.set_shader(load(shader))
			meshes.append(shader_mesh)
			add_child(shader_mesh)
		elif "sc_" in shader:
			sc_count += 1
			var shader_rect = ColorRect.new()
			shader_rect.size = Vector2(20.0, 20.0)
			shader_rect.position = Vector2(40.0 * (sc_count + 1), 40.0)
			shader_rect.material = ShaderMaterial.new()
			shader_rect.material.set_shader(load(shader))
			rects.append(shader_rect)
			$CSGen.add_child(shader_rect)
	Global.printc("[ShaderCacheGen] finished compiling shaders ("
		+ str(sp_count) + " spatial and " + str(sc_count) + " canvas).")

var frame = 0
func _process(_delta):
	if frame == 5: _load_shaders()
	if frame <= 6: frame += 1
