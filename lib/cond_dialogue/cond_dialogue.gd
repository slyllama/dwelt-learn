extends Node3D

@export var object_name = "ignore"
@export var dialogue_close_distance = 7.0
@export_file("*.json") var dialogue_data_file

var dialogue_data = {}

func _play_dialogue():
	Global.dialogue_played.emit({
		"title": "test",
		"data": ["1", "2"],
		"character": "fourier"})

func _close_dialogue():
	Global.dialogue_closed_early.emit()

func _ready():
	if dialogue_data_file != null:
		var get_file = FileAccess.open(dialogue_data_file, FileAccess.READ)
		dialogue_data = JSON.parse_string(get_file.get_as_text())
		get_file.close()
		Global.printc(dialogue_data, "yellow")
	
	# Object handler-specifics
	$ObjectHandler.object_name = object_name
	$ObjectHandler.activated.connect(_play_dialogue)
	$ObjectHandler.deactivated.connect(func():
		_close_dialogue())
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
