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
	Global.action_left.connect(func(): on_object = false)

func _process(_delta):
	if on_object == false:
		if _is_on_object() == true:
			on_object = true
			# Guaranteed to exist
			Global.look_object = get_collider().get_parent().object_name
			if Global.in_action == false:
				Global.interact_entered.emit()
	else:
		if _is_on_object() == false:
			on_object = false
			Global.look_object = ""
			Global.interact_left.emit()
