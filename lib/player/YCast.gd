extends RayCast3D

var over_area = false

func _physics_process(_delta):
	pass
	#if get_collider() != null:
		#Global.raycast_y_point = get_collision_point().y
	#
	#if get_collider() != null:
		#if "TYPE" in get_collider():
			## Can also include the "IGNORE" variable to ignore on the Y-cast
			## while giving the interactable a name
			#if (get_collider().TYPE == "ignore"
				#or "IGNORE" in get_collider()): return
			#if over_area == false:
				#Global.emit_signal("interact_entered")
				#over_area = true
				#Global.in_area_name = get_collider().TYPE
		#else:
			#if over_area == true:
				#Global.emit_signal("interact_left")
				#over_area = false
				#Global.in_area_name = ""
