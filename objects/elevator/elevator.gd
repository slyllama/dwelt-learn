extends Node3D

@export var height = 2
@export var object_name = "elevator"

var active = false
var c_height = 4 # hight of an individual column

func activate():
	active = true
	$SmokeOverlay.activate()
	Global.last_used_object = object_name
	Global.in_action = true
	
	Global.emit_signal(
		"player_position_locked",
		position,
		Vector2(global_rotation_degrees.y, 0.0))

func _ready():
	for h in height:
		var column = $Column.duplicate()
		column.position.y = c_height + h * c_height
		add_child(column)

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		if Global.look_object == object_name:
			if Global.in_action == false and active == false:
				activate()
