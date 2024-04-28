extends CanvasLayer

@export var fps_lower_limit = 20

func _ready():
	$Render.text = ""
	Global.debug_toggled.connect(func():
		visible = Global.debug_state
		$Settings.visible = Global.debug_state)
	Global.debug_toggled.emit()

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug"):
		Global.debug_state = !Global.debug_state
		Global.debug_toggled.emit()

var i = 0

func _process(_delta):
	var colour = "green"
	$Details.text = str(Global.debug_details_text)
	var fps = Engine.get_frames_per_second()
	if fps < fps_lower_limit:
		colour = "red"
	$FPSCounter.text = ("[color=" + colour + "]"
		+ str(Engine.get_frames_per_second()) + "fps[/color]")
	
	# Only get render profiling data if the debugger is on (this is a little
	# more expensive). We also don't refresh this every frame
	if Global.debug_state == true:
		if i >= 10:
			var prim = Performance.get_monitor(
				Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
			var mem = Performance.get_monitor(
				Performance.RENDER_BUFFER_MEM_USED)
			$Render.text = "\nPrimitives: " + str(prim)
			$Render.text += "\nRender buffer: " + str(int(mem / 1000000)) + "MB"
			i = 0
	i += 1
