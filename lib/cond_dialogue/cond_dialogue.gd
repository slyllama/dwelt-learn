extends Node3D

@export var object_name = "ignore"
@export var dialogue_close_distance = 7.0
@export_file("*.json") var dialogue_data_file

var dialogue_data = {}

func _get_state_data(state):
	var error_print = "[CondDialogue] (" + str(dialogue_data_file) + ") syntax error."
	if !"states" in dialogue_data:
		Global.printc(error_print, "orange")
		return(["[Error]"])
	if !state in dialogue_data.states:
		Global.printc(error_print, "orange")
		return(["Error"])
	if !"data" in dialogue_data.states[state]:
		Global.printc(error_print, "orange")
		return(["Error"])
	return(dialogue_data.states[state].data)

func _play_dialogue():
	# Identify the correct dialogue
	Global.dialogue_played.emit({
		"title": dialogue_data.title,
		"data": _get_state_data("default"),
		"character": dialogue_data.character})

func _close_dialogue():
	Global.dialogue_closed_early.emit()

func _ready():
	if dialogue_data_file != null:
		var get_file = FileAccess.open(dialogue_data_file, FileAccess.READ)
		dialogue_data = JSON.parse_string(get_file.get_as_text())
		get_file.close()
	
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
