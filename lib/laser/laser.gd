extends Area3D
# TODO: make a generic area class

@export var TYPE = "laser"

var active = false
var in_area = false

func _input(_event):
	if in_area == false: return
	if Input.is_action_just_pressed("interact"):
		if active == false:
			active = true
			$Cable.set_active(true)
			Global.emit_signal(
				"player_position_locked",
				Vector3(position.x, 4.0, position.z),
				Vector2(90.0, 10.0), 40.0, 20.0)
			return
		else:
			$Cable.set_active(false)
			active = false
			Global.interact_left.emit() # hide overlay on leaving
			Global.player_position_unlocked.emit()
			return

func _physics_process(_delta):
	$Cable.position.x -= 0.01
	if Global.in_area_name == TYPE:
		if in_area == false: in_area = true
	else:
		if in_area == true: in_area = false
