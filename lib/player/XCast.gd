extends RayCast3D

var on_object = false

func _is_on_object():
	var o = false
	if get_collider() != null:
		var p = get_collider()
		if "object_name" in p:
			if "interactable" in p:
				# Prevent non-interactable objects from triggering this
				if p.interactable: o = true
			else: o = true
	return(o)

func _ready():
	# Forces the cast to re-update after leaving an action
	Action.deactivated.connect(func(): on_object = false)

func _process(_delta):
	if _is_on_object() == true:
		var oname = get_collider().object_name
		Action.target = oname
	
	if on_object == false:
		if _is_on_object() == true:
			var oname = get_collider().object_name
			if oname != "ignore":
				on_object = true
			else:
				Action.target = ""
				on_object = false
				return
			if Action.active == false:
				Action.targeted.emit()
	else:
		if _is_on_object() == false:
			Action.target = ""
			on_object = false
			Action.untargeted.emit()
