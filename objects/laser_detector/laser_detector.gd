extends StaticBody3D
# The laser cast looks for laser detectors; if it finds one it triggers it

const INIT_COLOR = Color.RED
const IGNORE = true

@export var delay_time = 1.0

signal activated
signal deactivated

var TYPE = "laser_detector"
var selected = false
var active = false
var caster = null

func _set_box_color(get_color):
	$Box.material_override.albedo_color = get_color

func set_active(get_caster):
	if selected == true: return
	selected = true
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_box_color, INIT_COLOR, Color.WHITE, 0.4)
	caster = get_caster
	
	if delay_time > 0.0:
		$DelayTimer.wait_time = delay_time
		$DelayTimer.start()
		return
	else:
		active = true
		activated.emit()

func set_inactive():
	if active == true:
		active = false
		deactivated.emit()
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_box_color, Color.WHITE, INIT_COLOR, 0.4)
	caster = null

func _ready():
	_set_box_color(INIT_COLOR)

func _process(_delta):
	if caster == null: return
	if caster.cast_is_on_type(TYPE) == false:
		selected = false
		$DelayTimer.stop()
		set_inactive()

func _on_delay_timer_timeout():
	if selected == true:
		active = true
		activated.emit()
