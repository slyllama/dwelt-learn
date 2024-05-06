extends Node3D

@export var dialogue_data: Array[String]
@export var object_name = "dialogue"
@export var dialogue_close_distance = 9.0

func _play_dialogue():
	Action.activate(object_name, false)
	Action.untargeted.emit()
	Global.dialogue_played.emit(dialogue_data)

func _close_dialogue():
	Global.dialogue_closed_early.emit()

func _ready():
	if dialogue_data == []: object_name = "ignore"
	# Object handler-specifics
	$ObjectHandler.object_name = object_name
	$ObjectHandler.activated.connect(_play_dialogue)
	$ObjectHandler.deactivated.connect(_close_dialogue)
	# Special action to callback dialogue closing after the fact
	Global.dialogue_closed.connect(func():
		if Action.last_target == object_name:
			$ObjectHandler.deactivate())

var count = 6
func _physics_process(_delta):
	if count == 0:
		if (Action.last_target != object_name
			or Global.dialogue_active == false): return
		count = 6 # don't do this every frame
		# Distance from the dialogue object to the player
		var distance = global_position.distance_to(Global.player_position)
		if distance > dialogue_close_distance:
			if Global.dialogue_active == true:
				$ObjectHandler.deactivate()
	count -= 1
