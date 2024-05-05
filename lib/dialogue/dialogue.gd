extends Node3D

@export var dialogue_data: Array[String]
@export var object_name = "dialogue"
@export var dialogue_close_distance = 9.0

func _play_dialogue():
	Utilities.enter_action(object_name, false)
	Global.dialogue_played.emit(dialogue_data)

func _close_dialogue():
	Utilities.leave_action()
	Global.dialogue_closed_early.emit()

func _interact():
	if Action.target == object_name:
		if Action.active == true: return
		if Global.dialogue_active == false:
			_play_dialogue()

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		_interact()

func _ready():
	if dialogue_data == []: object_name = "ignore"
	Global.skill_clicked.connect(func(skill_name):
		if skill_name == "interact":
			_interact())

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
				Global.dialogue_closed_early.emit()
	count -= 1
