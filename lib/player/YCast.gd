extends RayCast3D

func _physics_process(_delta):
	if get_collider() != null:
		Global.raycast_y_point = get_collision_point().y
	else: Global.raycast_y_point = 0.0
