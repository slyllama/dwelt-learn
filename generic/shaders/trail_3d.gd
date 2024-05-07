class_name Trail3D extends MeshInstance3D

const start_color = Color(1.0, 0.0, 0.0, 1.0)
const end_color = Color(0.0, 1.0, 0.0, 1.0)
## Y-velocity must pass this value in either direction for the trail to
## activate.
const velocity_point = 5.0

var enabled = true
var running = false
var og_pos
var points = []
var life_points = []

func _basis(): return(get_global_transform().basis)
func _origin(): return(get_global_transform().origin)

func _append_point():
	points.append(_origin())
	life_points.append(0.0)

func _remove_point(p):
	points.remove_at(p)
	life_points.remove_at(p)

func _ready():
	mesh = ImmediateMesh.new()
	og_pos = _origin()

# Player's y-position last frame
var _p_y = Global.player_position.y

func _process(delta):
	# An accurate way of determining whether the player is going up or down
	var player_y_delta = (_p_y - Global.player_position.y) * 10.0
	_p_y = Global.player_position.y

	if (Global.in_updraft_zone == true
		and player_y_delta < -1.0) or Action.in_glide == true:
		enabled = true
	else: enabled = false
	
	if (og_pos - _origin()).length() > 0.1 and enabled:
		_append_point()
		og_pos = _origin()
	
	var p = 0;
	var max_points = points.size()
	while p < max_points:
		life_points[p] += delta
		if life_points[p] > 1.0:
			_remove_point(p)
			p -= 1
			if p < 0: p = 0
		max_points = points.size()
		p += 1
	
	mesh.clear_surfaces()
	
	# Rendering
	if points.size() < 2: return
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(points.size()):
		var t = float(i) / (points.size() - 1.0)
		var current_color = start_color.lerp(end_color, 1 - t)
		mesh.surface_set_color(current_color)
		var t0 = float(i) / points.size()
		var t1 = t
		mesh.surface_set_uv(Vector2(t0, 0))
		mesh.surface_add_vertex(to_local(points[i] + Vector3(0.5, 0.0, 0.0)))
		mesh.surface_set_uv(Vector2(t1, 1))
		mesh.surface_add_vertex(to_local(points[i] - Vector3(0.5, 0.0, 0.0)))
	mesh.surface_end()
