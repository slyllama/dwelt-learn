extends CanvasLayer

@export var fps_lower_limit = 20

func _ready():
	$Render.text = ""
	Global.debug_toggled.connect(func():
		
		visible = Global.debug_state)
	Global.debug_toggled.emit()
	
	# Print debug statements to the screen as well as STDIN
	Global.printc_buffer_updated.connect(func():
		var printc_line_buffer = []
		var printc_str_buffer = ""
		var line_count = 0
		for l in Global.printc_buffer:
			for n in str(l).split("\n"):
				printc_line_buffer.insert(0, n)
		for l in printc_line_buffer:
			if line_count < 18:
				printc_str_buffer = str(l) + "\n" + printc_str_buffer
			line_count += 1
		$Console.text = printc_str_buffer)

func _input(event):
	if (Input.is_action_just_pressed("toggle_debug")
		or Utilities.is_joy_button(event, JOY_BUTTON_BACK)):
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

func _mouseover(): Global.button_hover.emit()

# Debug actions

func _on_print_save_data_pressed():
	Global.printc("[Save] Data: " + str(Save.save_data))

func _on_save_pressed(): Save.game_saved.emit()

func _on_reset_save_data_pressed():
	Save.reset_file()
	get_tree().change_scene_to_file("res://lib/loading/loading.tscn")

func _on_toggle_player_vis_pressed():
	Global.debug_player_visible = !Global.debug_player_visible
	if Global.debug_player_visible:
		$CmdPanel/CmdVBox/TogglePlayerVis.text = "Hide Player"
	else: $CmdPanel/CmdVBox/TogglePlayerVis.text = "Show Player"
	Global.debug_player_visibility_changed.emit()

func _on_reset_settings_pressed():
	DirAccess.remove_absolute("user://settings.json")
	DirAccess.remove_absolute("user://input_data.json")
	get_tree().change_scene_to_file("res://lib/loading/loading.tscn")
