extends "res://lib/world_loader/world_loader.gd"

func _ready():
	super()
	Global.debug_state = true
	Global.debug_toggled.emit()
	
	$VentFan/AnimationPlayer.play("Fan")
	%Sky.environment.volumetric_fog_enabled = false

	Save.save_loaded.connect(func():
		Global.printc("save_loaded (local)", "yellow")
		if Save.get_data(map_name, "laser_positions") == null:
			Save.set_data(map_name, "laser_positions", [])
			Global.printc("Adding laser_positions entry.", "yellow"))
	
	Save.load_from_file()
