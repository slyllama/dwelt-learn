extends RayCast3D

var over_area = false

func _physics_process(_delta):
	if get_collider() != null:
		Global.raycast_y_point = get_collision_point().y
	
	if get_collider() != null:
		if "TYPE" in get_collider():
			if get_collider().TYPE == "ignore": return
			if over_area == false:
				Global.emit_signal("interact_entered")
				over_area = true
				Global.in_area_name = get_collider().TYPE
			Global.debug_details_text += ("\n[color=yellow]Over: '"
				+ str(get_collider().TYPE) + "'[/color]")
		else:
			if over_area == true:
				Global.emit_signal("interact_left")
				over_area = false
				Global.in_area_name = ""
