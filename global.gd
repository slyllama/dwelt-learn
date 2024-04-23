extends Node

signal dialogue_played(dialogue)
signal dialogue_closed
signal dialogue_closed_early
signal interact_entered
signal interact_left

### Settings ###
signal blend_shadow_splits_changed
signal fov_changed(release)
signal mute_changed

const SCREEN_SIZE = Vector2(1920.0, 1080.0)
const SETTINGS = {
	"blend_shadow_splits": true,
	"fov": 75,
	"mute": false }
var settings = SETTINGS

### Game states ###

signal entered_keybind_select
signal left_keybind_select
signal player_position_locked(get_lock_pos, get_cam_facing, get_clamp_extent_x, get_clamp_extent_y)
signal player_position_unlocked

var can_move = true
var debug_details_text = "[Details]"
var dialogue_active = false
var dragging_control = false # sliders should report their position so they aren't trapped on camera pan
var in_action = false
var in_area_name = ""
var in_keybind_select = false
var looking_at = null

### World states ###
var player_position = Vector2.ZERO
var raycast_y_point = 0.0
