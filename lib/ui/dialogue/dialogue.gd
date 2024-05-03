extends CanvasLayer

signal opened
signal closed

const FTIME = 0.05
var NUMS = [
	"4354076982764985762487698756983276459876458745",
	"9548764307598769640698564359876249826498376598",
	"3847650110249287326987634444876587360908743658" 
]
var stagger = [5, 4, 3, 2, 1]
var transitioning = false

### Dialogue-specific variables
var current_dialogue = []
var current_place = 0

func _set_text(get_text):
	$Base/DText.text = get_text

func close_dialogue():
	$SmokeOverlay.deactivate()
	
	current_dialogue = []
	current_place = 0
	Global.dialogue_active = false
	Utilities.leave_action()
	emit_signal("closed")
	
	transitioning = true
	var fade_in = create_tween()
	fade_in.tween_property($Base, "modulate:a", 0.0, 0.25)
	await fade_in.finished
	visible = false
	$Base/DText.text = ""
	transitioning = false

func play_dialogue(get_dialogue):
	$SmokeOverlay.activate()
	$PlaySound.play()
	current_dialogue = get_dialogue
	current_place = 0
	
	# These are already set by interact_area, but dialogue won't necessarily
	# be called by area
	Global.dialogue_active = true
	Global.in_action = true
	$Base.modulate.a = 0.0
	visible = true
	emit_signal("opened")
	transitioning = true
	var fade_in = create_tween()
	fade_in.tween_property($Base, "modulate:a", 1.0, 0.1)
	await fade_in.finished
	transitioning = false
	play_phrase()

# Animate the presentation of a phrase
func play_phrase():
	if current_place != 0: $ContinueSound.play()
	if current_place > current_dialogue.size() - 1:
		#Global.interact_entered.emit()
		Global.dialogue_closed.emit()
		return
	transitioning = true
	var out_text
	var c = current_dialogue[current_place]
	for N in NUMS:
		out_text = ""
		while len(c) > len(N) - 1: N += N
		for i in range(0, len(c)):
			if c[i] != " ": out_text += N[i]
			else: out_text += " "
		_set_text(out_text)
		await get_tree().create_timer(FTIME).timeout
	for m in stagger:
		for i in range(0, len(c)):
			if i % m == 0: out_text[i] = c[i]
			_set_text(out_text)
		await get_tree().create_timer(FTIME).timeout
	
	_set_text(c)
	current_place += 1
	transitioning = false

func _ready():
	Global.setting_changed.connect(func(setting):
		if setting == "larger_ui":
			$Particles.position = Utilities.get_screen_center()
			$Particles/L.restart()
			$Particles/R.restart())
			
	Global.connect("dialogue_played", play_dialogue)
	Global.connect("dialogue_closed", close_dialogue)
	Global.connect("dialogue_closed_early", close_dialogue)
	visible = false

func _input(_event):
	if (transitioning == true or Global.dialogue_active == false
		or Global.in_keybind_select == true): return
	if Input.is_action_just_pressed("interact"):
		if Global.dialogue_active == true: play_phrase()

func _mouseover():
	Global.button_hover.emit()

func _on_proceed_pressed():
	if Global.dialogue_active == true: play_phrase()
