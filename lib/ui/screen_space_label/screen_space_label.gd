class_name ScreenSpaceLabel extends VisibleOnScreenNotifier3D

@export var display_text = "Screen-space text label"
@export var render_distance = 0

enum { IN, OUT }

var canvas = CanvasLayer.new()
var text_node = RichTextLabel.new()
var in_range = true

var fade_tween: Tween
func fade(dir):
	fade_tween = create_tween()
	if dir == OUT:
		fade_tween.tween_property(text_node, "modulate:a", 0.0, 0.3)
		fade_tween.tween_callback(func():
			if in_range == false: text_node.visible = false)
	elif dir == IN:
		text_node.visible = true
		text_node.modulate.a = 0.0
		fade_tween.tween_property(text_node, "modulate:a", 1.0, 0.3)

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
	
	screen_entered.connect(func(): canvas.visible = true)
	screen_exited.connect(func(): canvas.visible = false)
	canvas.visible = is_on_screen()

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
				fade(OUT)
		else:
			if !in_range:
				in_range = true
				fade(IN)
