extends "res://lib/world_loader/world_loader.gd"

func _ready():
	interact_objects = [
		$Insights/Insight, $Insights/Insight2, $FourierTest/DialogueArea, $Laser]
	
	super()
	Global.debug_state = true
	Global.debug_toggled.emit()

	$VentHandler.turn_off()

	Save.save_loaded.connect(func():
		if Save.get_data(map_name, "laser_kopa_orientation") != null:
			$Laser/Cast.rotation_degrees = Save.get_data(map_name, "laser_kopa_orientation"))
	proc_save() # trigger save loading now that customs have been added

func _on_laser_player_left(object_name, cast_rotation_degrees):
	Save.set_data(map_name, "laser_" + object_name + "_orientation", cast_rotation_degrees)
func _on_laser_detector_activated(): $VentHandler.turn_on()
func _on_laser_detector_deactivated(): $VentHandler.turn_off()
