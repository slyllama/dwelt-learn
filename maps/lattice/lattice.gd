extends "res://lib/world_loader/world_loader.gd"

func _ready():
	# Exclude these spots from ever casting shadows
	exclude_from_shadow.append($RocketLight)
	exclude_from_shadow.append($RockLight)
	
	super()
	%Player.set_model_scale(0.2)
