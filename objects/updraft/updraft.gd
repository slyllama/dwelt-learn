extends Node3D

@export var object_name = "updraft"
@export var target_speed = 0.3
@export var acceleration = 0.04

var player_in_area = false
var yv = 0.0
var yv_target = 0.0
var yv_ease = 0.0

func _on_updraft_area_entered(body):
	if body is CharacterBody3D:
		Global.updraft_zone = object_name
		Global.in_updraft_zone = true
		player_in_area = true

func _on_updraft_area_exited(body):
	if body is CharacterBody3D:
		Global.in_updraft_zone = false
		player_in_area = false
		yv_target = 0.0

func _ready():
	Action.glide_pressed.connect(func():
		# Should only attempt if the player is in *this* updraft
		if player_in_area == true and Global.updraft_zone == object_name:
			Global.camera_shaken.emit()
			$FG/Chroma.updraft()
			yv_target = target_speed)

func _physics_process(_delta):
	# This checks the *last* used updraft zone, not the *active* one
	if Global.updraft_zone != object_name or Action.active == true: return
	
	yv = lerp(yv, yv_target, acceleration)
	yv_ease = ease(yv, 0.4)
	Global.linear_movement_override.y = yv_ease
