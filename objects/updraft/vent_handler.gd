extends Node3D

# Vent handler - handles the turning on and off of updrafts
var is_running = true
var on_scale = 1.0

func turn_on():
	is_running = true
	on_scale = 1.0
	$VentFanSound.play() # temporary
	
	$Updraft.enabled = true
	$Updraft.visible = true

func turn_off():
	is_running = false
	on_scale = 0.0
	$VentFanSound.stop() # temporary
	
	$Updraft.enabled = false
	$Updraft.visible = false

func _ready():
	$VentFan/AnimationPlayer.play("Fan")

func _process(_delta):
	$VentFan/AnimationPlayer.speed_scale = lerp(
		$VentFan/AnimationPlayer.speed_scale, on_scale, 0.05)
