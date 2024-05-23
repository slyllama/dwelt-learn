extends "res://lib/world_loader/world_loader.gd"

const InsightProjectile = preload("res://objects/insight_projectile/insight_projectile.tscn")

func _ready():
	super()
	Global.debug_state = true
	Global.debug_toggled.emit()
	
	%Sky.environment.volumetric_fog_enabled = false
	$VentHandler.turn_off()

	Save.save_loaded.connect(func():
		if Save.get_data(map_name, "laser_kopa_orientation") != null:
			$Laser/Cast.rotation_degrees = Save.get_data(map_name, "laser_kopa_orientation"))
	proc_save() # trigger save loading now that customs have been added

func _input(_event):
	if Input.is_action_just_pressed("debug_action"):
		var inp = InsightProjectile.instantiate()
		add_child(inp)
		
		inp.global_position = Global.player_position
		inp.rotation_degrees.y = Global.camera_y_rotation + 90.0

func _on_laser_player_left(object_name, cast_rotation_degrees):
	Save.set_data(map_name, "laser_" + object_name + "_orientation", cast_rotation_degrees)
func _on_laser_detector_activated(): $VentHandler.turn_on()
func _on_laser_detector_deactivated(): $VentHandler.turn_off()
