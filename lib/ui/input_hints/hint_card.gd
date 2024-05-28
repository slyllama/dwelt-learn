extends Panel

@export var title: String = "Input Hint"
@export var description: String = "Input hint description."
@export var key_text = ["#"]

var key_panels = []

func _action_in_input_data(action):
	for i in Utilities.input_data:
		if action == i.id: return(true)
	return(false)

func _set_trans(val, white = true):
	var ease_val = ease(val, 2.0)
	modulate.a = val
	if white == true: material.set_shader_parameter("base_color", 1.0 - ease_val)
	material.set_shader_parameter("alpha_scale", val * 0.85)

func fade_out(white = true):
	var fade = create_tween()
	fade.tween_method(_set_trans.bind(white), 1.0, 0.0, 0.3)

func update_input():
	for k in key_panels: k.queue_free() # reset array of keys
	if Global.input_mode == Global.InputModes.CONTROLLER: pass
	if Global.input_mode == Global.InputModes.KEYBOARD:
		for key in key_text:
			var pane = $Container/KeyPanelTemplate.duplicate()
			pane.visible = true
			$Container.add_child(pane)
			$Container.move_child(pane, 1)
			key_panels.append(pane)
			
			if _action_in_input_data(key):
				pane.get_node("Key").text = Utilities.cntr(
					Utilities.get_key(key).left(2))
			else: pane.get_node("Key").text = Utilities.cntr(str(key))

func _ready():
	modulate.a = 1.0
	$Container/TextContainer/Title.text = str(title).to_upper()
	$Container/TextContainer/Description.text = description
	Global.input_mode_switched.connect(update_input)
	update_input()
	
	var fade = create_tween()
	fade.tween_method(_set_trans, 0.0, 1.0, 0.2)
