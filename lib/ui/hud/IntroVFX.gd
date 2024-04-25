extends ColorRect

@export var runtime = 0.4

const MAX_ALPHA = 1.0
const MAX_SIZE = 0.0
var max_alpha = MAX_ALPHA
var max_size = MAX_SIZE

# 'at' is a value from 0.0 to 1.0; all parameters should be set off this value
func _trans_vfx_params(at):
	material.set_shader_parameter("size", max_size + (1.0 - max_size) * at)
	material.set_shader_parameter("exponent", 1.0 + at * 2.0)
	material.set_shader_parameter("darkness", (1.0 - at) * 0.5)
	material.set_shader_parameter("overall_alpha", max_alpha - max_alpha * at)

func transition_vfx_in():
	var vfx_tween = create_tween()
	vfx_tween.tween_method(_trans_vfx_params, 1.0, 0.0, runtime)

# Plays a less intense version of the former
func transition_subtle_vfx_in():
	max_alpha = 0.75
	max_size = 0.8
	transition_vfx_in()

func transition_vfx_out():
	var vfx_tween = create_tween()
	vfx_tween.tween_method(_trans_vfx_params, 0.0, 1.0, runtime)
	await vfx_tween.finished
	max_alpha = MAX_ALPHA
	max_size = MAX_SIZE

func _ready():
	Global.dialogue_played.connect(transition_subtle_vfx_in.unbind(1))
	Global.dialogue_closed.connect(transition_vfx_out)
	Global.dialogue_closed_early.connect(transition_vfx_out)
	Global.player_position_locked.connect(transition_subtle_vfx_in.unbind(4))
	Global.player_position_unlocked.connect(transition_vfx_out)
	
	material.set_shader_parameter("size", max_size)
	await get_tree().create_timer(0.2).timeout;
	transition_vfx_out()
