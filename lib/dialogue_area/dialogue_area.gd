extends Area3D

@export var TYPE = "test"
@export var dialogue_data: Array[String]

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		if dialogue_data == [] or Global.dialogue_active == true: return
		if Global.in_area_name == TYPE:
			Global.emit_signal("dialogue_played", dialogue_data)
