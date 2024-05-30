class_name ScreenSpaceLabel extends VisibleOnScreenNotifier3D

@export var display_text = "Screen-space text label"
@export var render_distance = 0

var canvas = CanvasLayer.new()
var text_node = RichTextLabel.new()
var in_range = true

func set_text(get_text):
	text_node.text = Utilities.cntr(get_text)

func _ready():
	add_child(canvas)
	
	text_node.size = Vector2(500.0, 500.0)
	text_node.text = Utilities.cntr(display_text)
	text_node.scroll_active = false
	text_node.bbcode_enabled = true
	text_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_node.add_theme_font_override("normal_font", load("res://generic/fonts/plex_mono.otf"))
	canvas.add_child(text_node)
	
	screen_entered.connect(func(): text_node.visible = true)
	screen_exited.connect(func(): text_node.visible = false)
	text_node.visible = is_on_screen()

func _process(_delta):
	if Global.camera_reference == null: return
	if !is_on_screen(): return
	text_node.position = Global.camera_reference.unproject_position(global_position)
	text_node.position.x -= 250.0

	if render_distance > 0:
		var dist = global_position.distance_to(Global.player_position)
		if dist > render_distance:
			if in_range:
				in_range = false
				canvas.visible = false
		else:
			if !in_range:
				in_range = true
				canvas.visible = true
