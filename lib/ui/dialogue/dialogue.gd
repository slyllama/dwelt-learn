extends CanvasLayer

signal opened
signal closed

var transitioning = false

### Dialogue-specific variables
var current_dialogue = []
var current_title = ""
var current_place = 0

func _set_base_exponent(exponent):
	$Base.material.set_shader_parameter("exponent", 0.05 + (1.0 - exponent) * 10.0)
	$Base.material.set_shader_parameter("alpha_scale", exponent)
	$Base.modulate.a = exponent

func _set_text(get_text):
	$Base/DText.text = get_text

func _format_text(get_text): # add proper dashes, colours, etc
	var out_text = get_text.replace("--", "\u2013")
	out_text = out_text.replace("<", "[color=#66b5ff]")
	out_text = out_text.replace(">", "[/color]")
	out_text = out_text.replace("$", "[font_size=6] [/font_size]")
	return(out_text)

func close_dialogue():
	Global.smoke_faded.emit("out")
	Global.dialogue_active = false
	
	current_dialogue = []
	current_title = ""
	current_place = 0
	
	emit_signal("closed")
	Global.input_hint_cleared.emit()
	
	transitioning = true
	var fade_in = create_tween()
	fade_in.tween_method(_set_base_exponent, 1.0, 0.0, 0.1)
	await fade_in.finished
	visible = false
	$Base/DText.text = ""
	transitioning = false

func play_dialogue(get_dialogue):
	$PlayDialogue.play()
	Global.smoke_faded.emit("in")
	Global.input_hint_played.emit([
		{ "title": "PROCEED", "description": "Continue dialogue.", "key": str(Utilities.get_key("interact")) } ], 0.0)
	current_dialogue = get_dialogue.data
	current_title = str(_format_text(get_dialogue.title)).to_upper()
	current_place = 0
	
	# Show a 3D character, if there is one
	if "character" in get_dialogue:
		if get_dialogue.character != "":
			$Base/VP3D.visible = true
			$Base/VP3D/DialogueWorld.load_model(get_dialogue.character)
		else: $Base/VP3D.visible = false
	else: $Base/VP3D.visible = false

	# These are already set by interact_area, but dialogue won't necessarily
	# be called by area
	Global.dialogue_active = true
	visible = true
	emit_signal("opened")
	transitioning = true
	var fade_in = create_tween()
	fade_in.tween_method(_set_base_exponent, 0.0, 1.0, 0.1)
	await fade_in.finished
	transitioning = false
	play_phrase()

# Animate the presentation of a phrase
func play_phrase():
	if current_place != 0: $ContinueSound.play()
	if current_place > current_dialogue.size() - 1:
		Global.dialogue_closed.emit()
		return
	_set_text(_format_text(current_dialogue[current_place]))
	
	transitioning = true
	$Base/DTitle.animate(current_title)
	await $Base/DTitle.anim_finished
	current_place += 1
	transitioning = false

func _ready():
	Global.connect("dialogue_played", play_dialogue)
	Global.connect("dialogue_closed", close_dialogue)
	Global.connect("dialogue_closed_early", close_dialogue)
	visible = false

func _input(_event):
	if (transitioning == true or Global.dialogue_active == false
		or Global.in_keybind_select == true): return
	if Input.is_action_just_pressed("interact"):
			if Global.dialogue_active == true: play_phrase()

func _mouseover(): Global.button_hover.emit()

func _on_proceed_pressed():
	if Global.dialogue_active == true: play_phrase()
