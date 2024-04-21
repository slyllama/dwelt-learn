extends CSGCylinder3D

var start = Vector3(-16.0, 6.0, 5.0)
var active = false

func set_active(get_active):
	active = get_active
	if active == true: visible = true
	else: visible = false

func _ready():
	set_active(false)

func _process(_delta):
	if active == false: return
	var end = Global.player_position + Vector3(0, -0.45, 0)
	global_position = (start + end) / 2.0
	look_at(end, Vector3.UP)
	rotation_degrees.x += 90.0
	
	height = global_position.distance_to(end) * 2.0
	$Sparks.look_at(end, Vector3.UP)
	$Sparks.position.y = height / 2.0
	$Glow.look_at(end, Vector3.UP)
	$Glow.position.y = height / 2.0
	material.set_shader_parameter("UVXScale", height * 0.02 + 3.0)
