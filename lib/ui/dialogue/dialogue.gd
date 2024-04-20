extends CanvasLayer

const FTIME = 0.05
var NUMS = [
	"4354076982764985762487698756983276459876458745",
	"9548764307598769640698564359876249826498376598",
	"3847650110249287326987634444876587360908743658" 
]
var stagger = [5, 4, 3, 2, 1]
var transitioning = false
var active = false

### Dialogue-specific variables
var current_dialogue = []
var current_place = 0

func _set_text(get_text):
	$Base/DText.text = "[center]" + get_text + "[/center]"

func close_dialogue():
	current_dialogue = ""
	current_place = 0
	active = false
	
	transitioning = true
	var fade_in = create_tween()
	fade_in.tween_property($Base, "modulate:a", 0.0, 0.1)
	await fade_in.finished
	visible = false
	transitioning = false

func play_dialogue(get_dialogue):
	current_dialogue = get_dialogue
	current_place = 0
	active = true
	$Base/Proceed.visible = false
	$Base.modulate.a = 0.0
	visible = true
	
	transitioning = true
	var fade_in = create_tween()
	fade_in.tween_property($Base, "modulate:a", 1.0, 0.1)
	await fade_in.finished
	transitioning = false
	
	play_phrase()

# Animate the presentation of a phrase
func play_phrase():
	if current_place > current_dialogue.size() - 1:
		close_dialogue()
		return
	
	$Base/Proceed.visible = false
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
		$Letter.play()
		await get_tree().create_timer(FTIME).timeout
	for m in stagger:
		for i in range(0, len(c)):
			if i % m == 0: out_text[i] = c[i]
			_set_text(out_text)
		$Letter.play()
		await get_tree().create_timer(FTIME).timeout
	
	_set_text(c)
	$Base/Proceed.visible = true
	current_place += 1
	transitioning = false

func _ready():
	visible = false
	$Base/Proceed.visible = false

func _input(_event):
	if transitioning == true or active == false: return
	if Input.is_action_just_pressed("ui_accept"):
		if active == true: play_phrase()

func _on_proceed_pressed():
	play_phrase()
