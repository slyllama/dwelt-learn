extends StaticBody3D
# The laser cast looks for laser detectors; if it finds one it triggers it

var TYPE = "laser_detector"
var active = false
var caster = null

func set_active(get_caster):
	if active == true: return
	active = true
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_box_lightness, 0.0, 1.0, 0.4)
	caster = get_caster

func set_inactive():
	active = false
	var fade_tween = create_tween()
	fade_tween.tween_method(_set_box_lightness, 1.0, 0.0, 0.4)
	caster = null

func _set_box_lightness(lightness):
	$Box.material_override.albedo_color = Color(lightness, lightness, lightness)

func _ready():
	_set_box_lightness(0.0)

func _process(_delta):
	if active == false: return
	if caster.cast_is_on_type(TYPE) == false:
		set_inactive()
