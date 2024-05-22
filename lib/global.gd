extends Node

const SCREEN_SIZE = Vector2(1920.0, 1080.0)
const MIN_SCREEN_SIZE = Vector2(800.0, 600.0)
const LARGE_UI_SCALE = 1.0

signal camera_shaken
signal button_hover
signal button_click
signal dialogue_played(dialogue)
signal dialogue_closed
signal dialogue_closed_early
signal entered_keybind_select
signal input_hint_played(data, clear_time)
signal input_hint_cleared
signal insight_pane_opened(dialogue_data)
signal insight_pane_closed
signal left_keybind_select
signal mouse_captured
signal mouse_released
signal shaders_loaded # called after ShaderCacheGen has loaded and removed itself
signal skill_clicked(skill_name)
signal smoke_faded(dir)

var in_keybind_select = false
var mouse_is_captured = false
var mouse_in_settings_menu = false

### Debug signals and parameters

signal debug_toggled
signal debug_player_visibility_changed
signal printc_buffer_updated

const PRINTC_BUFFER_SIZE = 30

var debug_details_text = "[Details]"
var debug_state = false
var debug_player_visible = true
var printc_buffer = []

func printc(string, color = "white", no_stdin = false):
	var string_fmt = "[color=" + color + " ]" + str(string) + "[/color]" # add color
	if no_stdin == false: print_rich(string_fmt)
	printc_buffer.append(string_fmt)
	printc_buffer_updated.emit()
	if printc_buffer.size() > PRINTC_BUFFER_SIZE:
		for i in printc_buffer.size() - PRINTC_BUFFER_SIZE:
			printc_buffer.pop_front()

### Settings ###
signal setting_changed(setting_id)
signal input_changed
var SETTINGS = {
	"fov": 80,
	"camera_sensitivity": 0.65,
	"volume": 1.00,
	"full_screen": false,
	"volumetric_fog": true,
	"bloom": true
}
var settings = SETTINGS.duplicate()
var input_data_loaded = false
var original_input_data = []
var settings_opened = false

### Game states ###
signal player_position_locked(get_lock_pos, get_cam_facing)
signal player_position_unlocked

var can_move = true
var current_map = ""
var dialogue_active = false
var dragging_control = false # sliders should report their position so they aren't trapped on camera pan
var gravity = 0.98
var in_updraft_zone = false
var linear_movement_override = Vector3.ZERO
var player_y_velocity = 0.0
var updraft_zone = ""

### Insights ###
signal insights_counted # emitted when the WorldLoader has counted how many insights there are

var insights_collected = 0
var insights_total = 0

### World states ###
var player_position = Vector3.ZERO
var player_ground_position = Vector3.ZERO
var raycast_y_point = 0.0
var look_point = null
