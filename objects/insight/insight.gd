extends Node3D

@export var object_name = "insight_test"
signal insight_activated

func _ready():
	$ObjectHandler.object_name = object_name

func _on_object_handler_activated():
	Action.activate(object_name, false)
	Action.untargeted.emit()
