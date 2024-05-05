extends Node

const SCREEN_SIZE = Vector2(1920.0, 1080.0)
const LARGE_UI_SCALE = 1.3

signal action_entered
signal action_left
signal camera_shaken
signal button_hover
signal button_click
signal debug_toggled
signal dialogue_played(dialogue)
signal dialogue_closed
signal dialogue_closed_early
signal entered_keybind_select
signal interact_entered
signal interact_left
signal left_keybind_select
signal mouse_captured
signal mouse_released
signal shaders_loaded # called after ShaderCacheGen has loaded and removed itself
signal skill_clicked(skill_name)

var debug_details_text = "[Details]"
var debug_state = false
var in_keybind_select = false
var mouse_is_captured = false
var mouse_in_settings_menu = false

### Settings ###
signal setting_changed(setting_id)
signal input_changed
var SETTINGS = {
	"fov": 75,
	"camera_sens": 0.65,
	"volume": 1.00,
	"spot_shadows": true,
	"vol_fog": true,
	"fancy_particles": true,
	"full_screen": false,
	"larger_ui" : false
}
var settings = SETTINGS.duplicate()
var input_data_loaded = false
var original_input_data = []

### Game states ###
signal player_position_locked(get_lock_pos, get_cam_facing)
signal player_position_unlocked

var can_move = true
var dialogue_active = false
var dragging_control = false # sliders should report their position so they aren't trapped on camera pan
var in_action = false
var linear_movement_override = Vector3.ZERO

### World states ###
var player_position = Vector2.ZERO
var raycast_y_point = 0.0
var look_point = null
var look_object = ""
var last_used_object = ""
