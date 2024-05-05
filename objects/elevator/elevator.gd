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
	$SmokeOverlay.activate()
	$EnterLaser.play()
	Utilities.enter_action(object_name, false)
	
	Global.emit_signal(
		"player_position_locked",
		global_position,
		Vector2(global_rotation_degrees.y, 0.0))

func deactivate():
	target_speed = 0.0
	
	await get_tree().create_timer(0.2).timeout
	active = false
	$SmokeOverlay.deactivate()
	Utilities.leave_action()
	Global.player_position_unlocked.emit()

func _interact():
	if Global.look_object == object_name:
		if Global.in_action == false and active == false:
			activate()

func _ready():
	Global.skill_clicked.connect(func(skill_name):
		if skill_name == "interact":
			_interact())
	
	height_units = c_height + height * c_height
	for h in height:
		var column = $Column.duplicate()
		column.position.y = c_height + h * c_height
		add_child(column)
	$Floor.position.y = height_units - 2.0

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		_interact()

func _physics_process(_delta):
	Global.linear_movement_override.y = lerp(
		Global.linear_movement_override.y, target_speed, 0.08)
	
	if active == false or height_units == null: return
	if Global.player_position.y >= height_units:
		deactivate()
