extends StaticBody3D
# The laser cast looks for laser detectors; if it finds one it triggers it

const INIT_COLOR = Color.RED

var TYPE = "laser_detector"
var active = false
var caster = null

func _set_box_color(get_color):
	$Box.material_override.albedo_color = get_color

func set_active(get_caster):
	if active == true: return
	active = true
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_box_color, INIT_COLOR, Color.WHITE, 0.4)
	caster = get_caster

func set_inactive():
	active = false
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_box_color, Color.WHITE, INIT_COLOR, 0.4)
	caster = null

func _ready():
	_set_box_color(INIT_COLOR)

func _process(_delta):
	if active == false: return
	if caster.cast_is_on_type(TYPE) == false:
		set_inactive()
