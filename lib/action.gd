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
