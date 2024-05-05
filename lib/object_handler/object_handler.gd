extends Area3D
# object_handler.gd
# A generic object handler. it looks out for action events and fires signals
# which can be used by its parent class. The aim here is to provide a single
# object handler for every kind of action - dialogue, machines, elevators etc.

signal activated
signal deactivated
var active = false
var object_name

func _interact():
	if Action.target == object_name:
		if Action.active == false and active == false:
			activated.emit()
			return
	if active == true:
		deactivated.emit()
		return

func _ready():
	Global.skill_clicked.connect(func(skill_name):
		if skill_name == "interact":
			_interact())

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		_interact()
