extends ColorRect

@export var runtime = 0.4

const MAX_ALPHA = 1.0
const MAX_SIZE = 0.0
var max_alpha = MAX_ALPHA
var max_size = MAX_SIZE

var active = false

# 'at' is a value from 0.0 to 1.0; all parameters should be set off this value
func _trans_vfx_params(at):
	material.set_shader_parameter("size", max_size + (1.0 - max_size) * at)
	material.set_shader_parameter("exponent", 1.0 + at * 2.0)
	material.set_shader_parameter("darkness", (1.0 - at) * 0.5)
	material.set_shader_parameter("overall_alpha", max_alpha - max_alpha * at)

func transition_vfx_in():
	active = true
	visible = true
	var vfx_tween = create_tween()
	vfx_tween.tween_method(_trans_vfx_params, 1.0, 0.0, runtime)

# Plays a less intense version of the former
func transition_subtle_vfx_in():
	active = true
	visible = true
	max_alpha = 0.75
	max_size = 0.8
	transition_vfx_in()

func transition_vfx_out():
	active = false
	var vfx_tween = create_tween()
	vfx_tween.tween_method(_trans_vfx_params, 0.0, 1.0, runtime)
	vfx_tween.tween_callback(func():
		if active == false:
			visible = false)
	await vfx_tween.finished
	max_alpha = MAX_ALPHA
	max_size = MAX_SIZE

func _ready():
	material.set_shader_parameter("size", max_size)
	Global.shaders_loaded.connect(func():
		await get_tree().create_timer(0.1).timeout
		transition_vfx_out())
	
	Global.dialogue_played.connect(transition_subtle_vfx_in.unbind(1))
	Global.dialogue_closed.connect(transition_vfx_out)
	Global.dialogue_closed_early.connect(transition_vfx_out)
	
	Global.player_position_locked.connect(transition_subtle_vfx_in.unbind(2))
	Global.player_position_unlocked.connect(transition_vfx_out)
