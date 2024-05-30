extends Node3D

@export var object_name = "ignore"
@export var dialogue_close_distance = 7.0
@export_file("*.json") var dialogue_data_file

var dialogue_data = {}

func _get_latest_data():
	var error_print = "[CondDialogue] (" + str(dialogue_data_file) + ") syntax error."
	if !"states" in dialogue_data:
		Global.printc(error_print, "orange")
		return(["[Error]"])
	
	# Run through states. If their conditions are true and their priority is
	# higher than the current highest, update both data and priority.
	var current_data = []
	var highest_priority = 0
	
	# TODO: only handles equality for a start
	for s in dialogue_data.states:
		if s == "default": continue
		var condition_met = true
		
		var state = dialogue_data.states[s]
		
		for statement in state.depends.split(","):
			Global.printc(statement, "green")
			var cond = statement.split(" ")[0]
			var cond_value_string = statement.split(" ")[2]
			var cond_value
			if cond_value_string == "true": cond_value = true
			else: cond_value = false
			
			Global.printc("---", "yellow")
			Global.printc("data = " + str(state.data), "yellow")
			Global.printc("cond = " + str(cond), "yellow")
			Global.printc("cond_value = " + str(cond_value), "yellow")
			
			var saved_cond = Save.get_data(Global.current_map, cond)
		
			if saved_cond != null:
				if saved_cond != cond_value: condition_met = false
			else: condition_met = false
		if condition_met and int(state.priority) >= highest_priority:
			current_data = state.data
			highest_priority = int(state.priority)
	
	if current_data == []: current_data = dialogue_data.states["default"].data
	Global.printc("elected: " + str(current_data))
	return(current_data)

func _play_dialogue():
	# Identify the correct dialogue
	Global.dialogue_played.emit({
		"title": dialogue_data.title,
		"data": _get_latest_data(),
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
