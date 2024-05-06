extends RayCast3D

var on_object = false

func _is_on_object():
	var o = false
	if get_collider() != null:
		if "object_name" in get_collider().get_parent():
			o = true
	return(o)

func _ready():
	# Forces the cast to re-update after leaving an action
	Action.deactivated.connect(func(): on_object = false)

func _process(_delta):
	if on_object == false:
		if _is_on_object() == true:
			var oname = get_collider().get_parent().object_name
			if oname != "ignore":
				on_object = true
				Action.target = oname
			else:
				on_object = false
				Action.target = ""
				return
			if Action.active == false:
				Action.targeted.emit()
	else:
		if _is_on_object() == false:
			on_object = false
			Action.target = ""
			Action.untargeted.emit()
