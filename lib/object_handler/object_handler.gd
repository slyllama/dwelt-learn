extends Area3D
# object_handler.gd
# A generic object handler. it looks out for action events and fires signals
# which can be used by its parent class. The aim here is to provide a single
# object handler for every kind of action - dialogue, machines, elevators etc.

## This object name is used by the action handler and must be specified by the
## parent scene.
@export var object_name = "none"
@export var cube_size = 3.0
@export var can_toggle_action = true

signal activated
signal deactivated
var active = false
var ignore_dialogue = false

func set_ignore_dialogue(state):
	ignore_dialogue = state

func activate():
	Action.activate(object_name, can_toggle_action)
	active = true
	activated.emit()

func deactivate():
	if active == false: return
	# Prevent issues in cases where an action is performed after dialogue
	if ignore_dialogue == false:
		if Global.dialogue_active or Action.in_insight_dialogue: return
	Action.deactivate()
	active = false
	deactivated.emit()

func _interact():
	if Action.target == object_name:
		if Action.active == false and active == false:
			activate()
			return
	if active == true and can_toggle_action == true:
		deactivate()
		return

func _ready():
	Global.skill_clicked.connect(func(skill_name):
		if skill_name == "interact": _interact())
	$Collision.shape.set_size(Vector3(cube_size, cube_size, cube_size))

func _input(event):
	if (Input.is_action_just_pressed("interact")
		or Utilities.is_joy_button(event, JOY_BUTTON_A)): _interact()
