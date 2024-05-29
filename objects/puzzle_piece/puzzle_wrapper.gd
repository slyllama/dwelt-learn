extends Node3D

var delay = false
var state = false

func _ready():
	$ObjectHandler.object_name = "puzzle_wrapper"

func _on_object_handler_activated():
	Global.input_hint_cleared.emit()

func _on_object_handler_triggered():
	if delay: return
	delay = true
	$DelayTimer.start()
	if !state:
		state = true
		$TestLever/AnimationPlayer.play("LeverPull")
	else:
		state = false
		$TestLever/AnimationPlayer.play_backwards("LeverPull")

func _on_delay_timer_timeout():
	delay = false
