extends Node

signal dialogue_played(dialogue)
signal interact_entered
signal interact_left

### Settings ###
signal blend_shadow_splits_changed
signal fov_changed
signal mute_changed

var blend_shadow_splits = true
var fov = 75
var mute = true

var debug_details_text = "[Details]"
var dialogue_active = false
var in_area_name = ""
var player_position = Vector2.ZERO
