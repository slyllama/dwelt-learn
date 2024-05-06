extends Node3D

var in_updraft = false
var target_upward = 0.0
var reached_apex = false

func _on_updraft_area_entered(body):
	if !body is CharacterBody3D: return
	in_updraft = true
	reached_apex = false
	target_upward = 0.0

func _physics_process(_delta):
	if in_updraft == true:
		target_upward += 0.01
	target_upward = clamp(target_upward, 0.0, 1.0)
	
	var val = ease(target_upward, -2.0)
	if val > 0.5:
		if reached_apex == false: Global.gravity = 0.1
		reached_apex = true
		val = 1.0 - val
	Global.linear_movement_override.y = val * 1.3
	
	if reached_apex == true:
		Global.gravity = lerp(Global.gravity, 0.98, 0.01)
