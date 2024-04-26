extends CanvasLayer

@export var fps_lower_limit = 20

func _ready():
	Global.debug_toggled.connect(func():
		visible = Global.debug_state
		$Settings.visible = Global.debug_state)
	Global.debug_toggled.emit()

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug"):
		Global.debug_state = !Global.debug_state
		Global.debug_toggled.emit()

func _process(_delta):
	
	var colour = "green"
	$Details.text = str(Global.debug_details_text)
	var fps = Engine.get_frames_per_second()
	if fps < fps_lower_limit:
		colour = "red"
	$FPSCounter.text = ("[color=" + colour + "]"
		+ str(Engine.get_frames_per_second()) + "fps[/color]")
