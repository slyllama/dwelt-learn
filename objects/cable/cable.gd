extends MeshInstance3D
#TODO: particles should come a little forward from the end of the cast point,
# so we can keep the depth test while avoiding clipping.

var start = Vector3(0.0, 0.0, 0.0)
var end = Vector3(1.0, 1.0, 1.0)

func toggle_end_point(state):
	if $Glow.visible != state:
		$Glow.visible = state
	if $Sparks.visible != state:
		$Sparks.visible = state

func update():
	global_position = (start + end) / 2.0
	look_at(end, Vector3.UP)
	rotation_degrees.x += 90.0
	
	mesh.height = global_position.distance_to(end) * 2.0
	$Sparks.look_at(end, Vector3.UP)
	$Sparks.position.y = mesh.height / 2.0 - 0.1
	$Glow.look_at(end, Vector3.UP)
	$Glow.position.y = mesh.height / 2.0 - 0.1

func _ready():
	# Avoid erroneous particles when the laser first updates its position
	await get_tree().create_timer(1.0).timeout
	$Sparks.emitting = true

func _process(_delta):
	update()
