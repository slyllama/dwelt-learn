extends RayCast3D

func _physics_process(_delta):
	if is_colliding():
		Global.look_point = get_collision_point()
	else: Global.look_point = null
