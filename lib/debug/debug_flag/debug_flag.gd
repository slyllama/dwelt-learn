@tool
class_name DebugFlag extends Marker3D
# debug_flag.gd
# Simple system for displaying debug points

@export var custom_texture: Texture2D

func _ready():
	var tex_to_use
	if custom_texture != null: tex_to_use = custom_texture
	else: tex_to_use = load("res://lib/debug/debug_flag/tex/flag_icon.png")
	
	var Flag = MeshInstance3D.new()
	Flag.position.y = 2.0
	Flag.cast_shadow = false
	Flag.mesh = QuadMesh.new()
	Flag.mesh.size = Vector2(0.5, 0.5)
	Flag.mesh.orientation = PlaneMesh.FACE_Z
	
	var FlagMaterial = ShaderMaterial.new()
	FlagMaterial.shader = load("res://generic/shaders/sp_flag.gdshader")
	FlagMaterial.set_shader_parameter("texture_albedo", tex_to_use)
	Flag.set_surface_override_material(0, FlagMaterial)
	
	add_child(Flag)
	
	if !Engine.is_editor_hint():
		Global.debug_toggled.connect(func(): visible = Global.debug_state)
