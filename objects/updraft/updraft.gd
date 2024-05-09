extends Node3D

@export var object_name = "updraft"

var player_in_area = false
var in_updraft = false
var target_upward = 0.0
var reached_apex = false

func _on_updraft_area_entered(body):
	if body is CharacterBody3D:
		Global.updraft_zone = object_name
		Global.in_updraft_zone = true
		player_in_area = true

func _on_updraft_area_exited(body):
	if body is CharacterBody3D:
		Global.in_updraft_zone = false
		player_in_area = false

func _ready():
	Action.glide_pressed.connect(func():
		# Should only attempt if the player is in *this* updraft
		if player_in_area == true and Global.updraft_zone == object_name:
			Global.camera_shaken.emit()
			$FG/Chroma.updraft()
			in_updraft = true
			reached_apex = false
			target_upward = 0.2)

func _physics_process(_delta):
	# This checks the *last* used updraft zone, not the *active* one
	if Global.updraft_zone != object_name: return
	if Action.active == true: return
	if in_updraft == true:
		target_upward += 0.01
	target_upward = clamp(target_upward, 0.0, 1.0)
	
	var val = ease(target_upward, -2.0)
	if val > 0.5:
		if reached_apex == false:
			in_updraft = false
		reached_apex = true
		val = 1.0 - val
	
	if reached_apex == true: target_upward = lerp(target_upward, 0.0, 0.03)
	Global.linear_movement_override.y = val
