extends "res://lib/world_loader/world_loader.gd"

func _ready():
	super()
	Global.debug_state = true
	Global.debug_toggled.emit()
	
	$VentFan/AnimationPlayer.play("Fan")
	%Sky.environment.volumetric_fog_enabled = false

	Save.save_loaded.connect(func():
		Global.printc("save_loaded (local)", "yellow")
		if Save.get_data(map_name, "laser_save_test_lasercast_position") != null:
			$Laser/Cast.rotation_degrees = Save.get_data(map_name, "laser_save_test_lasercast_position"))

	Save.load_from_file()

func _on_laser_player_left(object_name, cast_rotation_degrees):
	Global.printc("Left laser " + object_name + "!", "magenta")
	Save.set_data(map_name, "laser_" + object_name + "cast_position", cast_rotation_degrees)
