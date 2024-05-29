@tool
extends Area3D
# object_handler.gd
# A generic object handler. it looks out for action events and fires signals
# which can be used by its parent class. The aim here is to provide a single
# object handler for every kind of action - dialogue, machines, elevators etc.

signal triggered

## This object name is used by the action handler and must be specified by the
## parent scene.
@export var object_name = "none"
@export var collision_size = Vector3(1.0, 1.0, 1.0)
@export var can_toggle_action = true
@export var interactable = true # deactivations are still possible
## If [code]trigger_mode[/code] is enabled, all other entering/exiting logic
## will be ignored, and interacting with this object handler will simply
## propogate the [code]triggered[/code] signal.
@export var trigger_mode = false

signal activated
signal deactivated
var active = false

func activate():
	Action.activate(object_name, can_toggle_action)
	active = true
	activated.emit()

func deactivate():
	if active == false: return
	Action.deactivate()
	active = false
	deactivated.emit()

func _interact():
	if !interactable: return
	
	if trigger_mode and !Action.active and Action.target == object_name:
		triggered.emit()
		return
	
	if active and can_toggle_action:
		deactivate()
		return
	else:
		if Action.target == object_name:
			activate()
			return

func _ready():
	if !Engine.is_editor_hint():
		Global.skill_clicked.connect(func(skill_name):
			if skill_name == "interact": _interact())
	$Collision.shape.size = Vector3(collision_size)

func _input(_event):
	if Engine.is_editor_hint(): return
	if Input.is_action_just_pressed("interact"): _interact()
