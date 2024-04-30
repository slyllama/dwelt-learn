extends "res://lib/world_loader/world_loader.gd"

var og_position

func _ready():
	super()
	og_position = $Player.position

func _on_laser_detector_activated():
	Global.camera_shaken.emit()
