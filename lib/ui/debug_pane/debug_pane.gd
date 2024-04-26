extends CanvasLayer

@export var fps_lower_limit = 20

func _ready():
	visible = false

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug"):
		visible = !visible
		$Settings.visible = visible

func _process(_delta):
	var colour = "green"
	$Details.text = str(Global.debug_details_text)
	var fps = Engine.get_frames_per_second()
	if fps < fps_lower_limit:
		colour = "red"
	$FPSCounter.text = ("[color=" + colour + "]"
		+ str(Engine.get_frames_per_second()) + "fps[/color]")
