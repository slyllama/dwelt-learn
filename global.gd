extends Node

const SCREEN_SIZE = Vector2(1920.0, 1080.0)

signal camera_shaken
signal button_hover
signal debug_toggled
signal dialogue_played(dialogue)
signal dialogue_closed
signal dialogue_closed_early
signal interact_entered
signal interact_left
signal shaders_loaded # called after ShaderCacheGen has loaded and removed itself

### Settings ###

signal setting_changed(setting_id)
var SETTINGS = {
	"fov": 75,
	"camera_sens": 0.65,
	"volume": 0.00,
	"spot_shadows": false
}
var settings = SETTINGS.duplicate()

### Game states ###

signal entered_keybind_select
signal left_keybind_select
signal player_position_locked(get_lock_pos, get_cam_facing, get_clamp_extent_x, get_clamp_extent_y)
signal player_position_unlocked

var can_move = true
var debug_details_text = "[Details]"
var debug_state = false
var dialogue_active = false
var dragging_control = false # sliders should report their position so they aren't trapped on camera pan
var in_action = false
var in_area_name = ""
var in_keybind_select = false
var looking_at = null

### World states ###
var player_position = Vector2.ZERO
var raycast_y_point = 0.0
