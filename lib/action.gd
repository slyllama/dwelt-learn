extends Node
# action.gd
# The Action.* hosts all generic action events.

var active = false # is an action active?
var target = "" # the action currently targeted by the cursor
var last_target = "" # the last action which was targeted by the cursor

signal activated(toggle)
signal deactivated
signal targeted # action has been looked at by the cursor
signal untargeted # cursor has moved away from an action

# Perform all the logic and assignments for entering an action
func activate(object_name, can_toggle = true):
	active = true
	last_target = object_name
	activated.emit(can_toggle)

# Prevent issues when spamming the interact key, or trying to interact with a
# different object in range when already in an action
func deactivate():
	if active == false: return
	await get_tree().create_timer(0.2).timeout
	active = false
	deactivated.emit()
