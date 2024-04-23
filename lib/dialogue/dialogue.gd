extends Node3D

@export var TYPE = "test"
@export var dialogue_data: Array[String]

func _play_dialogue(): Global.dialogue_played.emit(dialogue_data)
func _close_dialogue(): Global.dialogue_closed_early.emit()

func _ready():
	$InteractArea.TYPE = TYPE
	$InteractArea.activated.connect(_play_dialogue)
	$InteractArea.deactivated.connect(_close_dialogue)
