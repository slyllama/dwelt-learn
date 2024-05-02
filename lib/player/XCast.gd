extends RayCast3D

func _stop_looking():
	if Global.look_object != "":
		Global.look_object = ""
		Global.interact_left.emit()

func _process(_delta):
	if is_colliding():
		Global.look_point = get_collision_point()
		var object = get_collider().get_parent()
		if object != null:
			if "object_name" in object:
				if object.object_name != Global.look_object:
					Global.look_object = object.object_name
					Global.interact_entered.emit()
			else: _stop_looking()
		else: _stop_looking()
	else:
		Global.look_point = null
		_stop_looking()
	if Global.in_action == true: _stop_looking()
