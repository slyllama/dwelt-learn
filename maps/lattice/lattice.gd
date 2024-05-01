extends "res://lib/world_loader/world_loader.gd"

func _ready():
	# Exclude these spots from ever casting shadows
	exclude_from_shadow.append($RocketLight)
	exclude_from_shadow.append($RockLight)
	
	super()
	%Player.set_model_scale(0.2)
	
	# Set a spicy angle
	%Player.rotation_degrees.y += 180.0
	%Player/CamPivot.rotation_degrees.x += 24.0
	%Player/CamPivot.new_cam_x_rotation += 24.0
	%Player/CamPivot.rotation_degrees.y += 10.0
	%Player/CamPivot.new_cam_y_rotation += 10.0
