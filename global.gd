extends Node

signal deco_triggered
signal interact_entered
signal interact_left

### Settings ###
var fov = 75
signal fov_changed
var mute = false
signal mute_changed
var blend_shadow_splits = true
signal blend_shadow_splits_changed

var debug_details_text = "[Details]"
var player_position = Vector2.ZERO
var in_area_name = ""
