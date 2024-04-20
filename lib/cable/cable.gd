extends CSGCylinder3D

var start = Vector3(-17.0, 5.0, -2.3)

func _ready():
	pass

func _process(_delta):
	var end = Global.player_position + Vector3(0, -0.45, 0)
	position = (start + end) / 2.0
	look_at(end, Vector3.UP)
	rotation_degrees.x += 90.0
	
	height = position.distance_to(end) * 2.0
	$Sparks.look_at(end, Vector3.UP)
	$Sparks.position.y = height / 2.0
	$Glow.look_at(end, Vector3.UP)
	$Glow.position.y = height / 2.0
	material.set_shader_parameter("UVXScale", height * 0.02 + 3.0)
