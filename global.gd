extends Node

signal dialogue_played(dialogue)
signal interact_entered
signal interact_left

### Settings ###
signal blend_shadow_splits_changed
signal fov_changed(release)
signal mute_changed

const SETTINGS = {
	"blend_shadow_splits": true,
	"fov": 75,
	"mute": false
}

var settings = SETTINGS

### Game states ###

signal entered_keybind_select
signal left_keybind_select

var can_move = true
var debug_details_text = "[Details]"
var dialogue_active = false
var in_area_name = ""
var in_keybind_select = false

### World states ###
var player_position = Vector2.ZERO
