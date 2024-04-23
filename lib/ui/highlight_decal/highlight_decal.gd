extends Decal

@export var debug_only = false

func _ready():
	if debug_only == true:
		visible = false

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug"):
		if debug_only == true:
			visible = !visible
