@tool
extends CanvasLayer

## Set this to true to skip straight to the loading screen
@export var debug_bypass = false
@export_multiline var copy_text: String

@onready var fade_tween
var can_interact = true

func _format_text(get_text): # add proper dashes, colours, etc
	var out_text = "[center]" + get_text.replace("--", "\u2013")
	out_text = out_text.replace("<", "[color=#66b5ff]")
	out_text = out_text.replace(">", "[/color]")
	out_text = out_text.replace("$", "[font_size=10] [/font_size]")
	return(out_text + "[/center]")

func go_to_menu():
	Global.button_click.emit()
	can_interact = false
	fade_tween = create_tween()
	fade_tween.tween_property($Container, "modulate:a", 0.0, 1.0)
	fade_tween.tween_callback(func():
		get_tree().change_scene_to_file("res://lib/loading/loading.tscn"))

func _ready():
	$Container/Proceed.grab_focus()
	if Engine.is_editor_hint():
		$Container/Text.text = _format_text(copy_text)
		return
	$Container.modulate.a = 0.0
	Utilities.configure_screen()
	await get_tree().create_timer(0.5).timeout
	
	if debug_bypass:
		get_tree().change_scene_to_file("res://lib/loading/loading.tscn")
	else:
		fade_tween = create_tween()
		fade_tween.tween_property($Container, "modulate:a", 1.0, 0.65)

func _input(_event):
	if Engine.is_editor_hint(): return
	if Input.is_action_just_pressed("interact"):
		if can_interact: go_to_menu()

func _on_proceed_pressed():
	if can_interact: go_to_menu()
