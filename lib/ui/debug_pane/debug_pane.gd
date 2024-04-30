extends CanvasLayer

@export var fps_lower_limit = 20
var marked_points = []
var marked_point_nodes = []
const PointMarker = preload("res://lib/ui/debug_pane/point_marker.tscn")

# Utilities for marking and clearing points
func mark_point_at_player():
	$ControlPanel/ControlVBox/ClearPoints.visible = true
	var snapped_point = Vector3(
		snapped(Global.player_position.x, 0.01),
		snapped(Global.player_position.y, 0.01),
		snapped(Global.player_position.z, 0.01))
	print("[Debug] marked point " + str(snapped_point) + ".")
	marked_points.append(snapped_point)
	var marker = PointMarker.instantiate()
	marker.position = snapped_point
	marker.position.y += 3.0
	marker.get_node("Label").text = str(snapped_point)
	add_child(marker)
	marked_point_nodes.append(marker)

func clear_points():
	$ControlPanel/ControlVBox/ClearPoints.visible = false
	print("[Debug] marked points: " + str(marked_points) + ".")
	marked_points = []
	for marker in marked_point_nodes: marker.queue_free()
	marked_point_nodes = []

func _ready():
	$Render.text = ""
	Global.debug_toggled.connect(func():
		visible = Global.debug_state)
	Global.debug_toggled.emit()

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug"):
		Global.debug_state = !Global.debug_state
		if Global.debug_state == false: clear_points()
		Global.debug_toggled.emit()
	if Input.is_action_just_pressed("debug_action"):
		if Global.debug_state == true: mark_point_at_player()

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

func _on_map_selection_pressed():
	get_tree().change_scene_to_file("res://lib/loading/loading.tscn")

func _on_mark_point_pressed(): mark_point_at_player()
func _on_clear_points_pressed(): clear_points()
func _mouseover(): Global.button_hover.emit()
