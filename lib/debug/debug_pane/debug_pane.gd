extends CanvasLayer

@export var fps_lower_limit = 20

# Special parameters for loading screen - hide certain elements
func update():
	var hide_nodes = [  # nodes to be hidden if not on a map (i.e., in the main menu)
		$Details, $Render, $CmdPanel/CmdVBox/Save, $CmdPanel/CmdVBox/Padding,
		$CmdPanel/CmdVBox/TogglePlayerVis, $CmdPanel/CmdVBox/Padding2,
		$CmdPanel/CmdVBox/ReturnToMenu ]
	if Global.current_map == "":
		for h in hide_nodes: h.visible = false
	else:
		for h in hide_nodes: h.visible = true
	Global.debug_toggled.emit()

func _ready():
	$Render.text = ""
	Global.debug_toggled.connect(func():
		visible = Global.debug_state)
	Global.debug_toggled.emit()
	
	Global.debug_popup_opened.connect(func():
		Global.debug_popup_is_open = true
		#$CmdPanel/CmdVBox/ClosePopup.grab_focus()
		$CmdPanel/CmdVBox.visible = true)
	Global.debug_popup_closed.connect(func():
		Global.debug_popup_is_open = false
		$CmdPanel/CmdVBox.visible = false)
	Global.debug_popup_closed.emit()
	
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

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug"):
		Global.debug_state = !Global.debug_state
		Global.debug_toggled.emit()
	
	if Input.is_action_just_pressed("right_click"):
		Global.debug_popup_closed.emit()

var i = 0
func _process(_delta):
	var colour = "green"
	var fps = Engine.get_frames_per_second()
	if fps < fps_lower_limit:
		colour = "red"
	$FPSCounter.text = ("[color=" + colour + "]"
		+ str(Engine.get_frames_per_second()) + "fps[/color]")
	
	if Global.current_map == "": return # no map data to retrieve
	$Details.text = str(Global.debug_details_text)
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

# Debug actions

func _on_save_pressed():
	Save.game_saved.emit()
	Global.debug_popup_closed.emit()

func _on_reset_save_data_pressed():
	Global.debug_state = false
	Global.debug_toggled.emit()
	Save.reset_file()
	get_tree().change_scene_to_file("res://lib/loading/loading.tscn")

func _on_toggle_player_vis_pressed():
	Global.debug_player_visible = !Global.debug_player_visible
	if Global.debug_player_visible:
		$CmdPanel/CmdVBox/TogglePlayerVis.text = "Hide player"
	else: $CmdPanel/CmdVBox/TogglePlayerVis.text = "Show player"
	Global.debug_player_visibility_changed.emit()
	Global.debug_popup_closed.emit()

func _on_reset_settings_pressed():
	Global.input_data_loaded = false # force this to be re-processed
	DirAccess.remove_absolute("user://settings.json")
	DirAccess.remove_absolute("user://input_data.json")
	get_tree().change_scene_to_file("res://lib/loading/loading.tscn")

func _on_return_to_menu_pressed():
	Save.game_saved.emit()
	get_tree().change_scene_to_file("res://lib/loading/loading.tscn")

func _on_emit_controller_input_pressed():
	Global.printc("[DebugPane] simulated joy button.", "yellow")
	var controller_test_event = InputEventJoypadButton.new()
	controller_test_event.pressed = true
	Input.parse_input_event(controller_test_event)
	Input.action_press("interact")
	Input.action_release("interact")
	controller_test_event.pressed = false

func _on_close_popup_pressed(): Global.debug_popup_closed.emit()

func _on_print_cam_rotation_pressed():
	Global.printc(Utilities.vecstr(Global.camera_rotation))
	Global.debug_popup_closed.emit()
