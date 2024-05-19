extends Node3D

@export var height = 2
@export var object_name = "elevator"
@export var elevator_speed = 2.0

var active = false
var c_height = 4 # hight of an individual column
var height_units
var target_speed = 0.0 # used for lerping

func activate():
	active = true
	target_speed = elevator_speed / 10.0
	Global.smoke_faded.emit("in")
	$EnterLaser.play()
	
	Global.emit_signal(
		"player_position_locked",
		global_position,
		Vector2(global_rotation_degrees.y, 0.0))

func deactivate():
	active = false
	target_speed = 0.0
	Global.smoke_faded.emit("out")
	Global.player_position_unlocked.emit()

func _ready():
	# Object handler-specifics
	$ObjectHandler.object_name = object_name
	$ObjectHandler.can_toggle_action = false
	$ObjectHandler.activated.connect(activate)
	$ObjectHandler.deactivated.connect(deactivate)
	
	height_units = c_height + height * c_height
	for h in height:
		var column = $Column.duplicate()
		column.position.y = c_height * 1.5 + h * c_height
		add_child(column)
	$Floor.position.y = height_units

var c = 0

func _physics_process(_delta):
	if active == false or height_units == null: return
	Global.linear_movement_override.y = lerp(
		Global.linear_movement_override.y, target_speed, 0.08)
	if Global.player_position.y >= height_units + 2.0:
		Global.linear_movement_override = Vector3.ZERO
		$ObjectHandler.deactivate()
