extends CanvasLayer

const INODE = preload("res://lib/ui/insight/tex/insight_node.png")
const PLACEHOLDER = preload("res://generic/tex/placeholder.png")
# Parameters for parallax offset
var mouse_pos
var center

var is_open = false
var insight_count = 7
var completed = 2

var insight_nodes = []
var completed_nodes = []

func _set_trans_state(val): # a value between 0 and 1 for tweening
	var ease_val = ease(val, -4.6)
	for j in insight_nodes:
		j.get_child(0).position.x = 250.0 + ease_val * 100.0
		j.get_child(0).modulate.a = ease_val
	var scale_val = 0.8 + 0.2 * ease_val
	$SpriteCenter.scale = Vector2(scale_val, scale_val)
	$SpriteCenter.modulate.a = ease_val
	$Darken.modulate.a = ease_val

func update_completed_nodes():
	completed = clamp(completed, 0, insight_count)
	for c in completed:
		var comp_node = Sprite2D.new()
		comp_node.texture = PLACEHOLDER
		comp_node.scale = Vector2(0.7, 0.7)
		comp_node.position = insight_nodes[c].get_child(0).position
		insight_nodes[c].get_child(0).add_child(comp_node)

func open():
	update_completed_nodes()
	$SmokeOverlay.activate()
	is_open = true
	visible = true
	var trans_tween = create_tween()
	trans_tween.tween_method(_set_trans_state, 0.0, 1.0, 0.3)

func close():
	$SmokeOverlay.deactivate()
	is_open = false
	var trans_tween = create_tween()
	trans_tween.tween_method(_set_trans_state, 1.0, 0.0, 0.25)
	trans_tween.tween_callback(func():
		if is_open == false: visible = false)

func _ready():
	mouse_pos = get_viewport().get_mouse_position()
	center = get_viewport().size
	visible = false
	
	for i in insight_count:
		var i_container = Node2D.new()
		i_container.rotation_degrees = 360.0 / insight_count * i
		$SpriteCenter.add_child(i_container)
		insight_nodes.append(i_container)
		
		var i_sprite = Sprite2D.new()
		i_sprite.scale = Vector2(0.55, 0.55)
		#i_sprite.position = Vector2(200, 0)
		i_sprite.texture = INODE
		i_container.add_child(i_sprite)
		
		for j in insight_nodes:
			j.get_child(0).rotation_degrees = - j.rotation_degrees

func _input(_event):
	if Input.is_action_just_pressed("debug_action"):
		if is_open == false:
			open()
			return
		else: close()

func _process(_delta):
	mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos == null: return
	
	var adj = Vector2(
		clamp(2.0 * mouse_pos.x / center.x - 1.0, -1.0, 1.0),
		clamp(2.0 * mouse_pos.y / center.y - 1.0, -1.0, 1.0))
	$SpriteCenter.set_pos(adj * 50.0, 0.08)
	$SpriteCenter.rotation_degrees += 0.1
	$SpriteCenter/Base2.position = adj * 30.0
	$SpriteCenter/Base2.rotation_degrees -= 0.12
	$SpriteCenter/Base3.rotation_degrees -= 0.07
