extends Node
# action.gd
# The Action.* hosts all generic action events.

var active = false # is an action active?
var target = "" # the action currently targeted by the cursor
var last_target = "" # the last action which was targeted by the cursor
var in_insight_dialogue = false

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

# Gliding-specific signals
# TODO: this is a better role-model for skill action handling and should be
# applied to interactions, too (inputs call these signals from their own homes;
# these signals are the 'root' messages which are picked up by other things
# such as updrafts)
signal glide_pressed # for entering an updraft
var in_glide = false
