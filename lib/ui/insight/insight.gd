extends CanvasLayer

const InsightFlame = preload("res://lib/ui/insight/insight_flame/insight_flame.tscn")

const INODE = preload("res://lib/ui/insight/tex/insight_node.png")
const PLACEHOLDER = preload("res://generic/tex/placeholder.png")
const BLUR = preload("res://objects/insight/tex/insight_blur.png")
const RANDOM = [0.01, 0.03, 0.02, 0.041, 0.012, 0.06, 0.032, 0.02, 0.06, 0.045]
# Parameters for parallax offset
var mouse_pos
var center

var is_open = false
var primed = false
var can_close = false

var insight_nodes = []
var completed_nodes = []
var line_nodes = []

func _set_trans_state(val): # a value between 0 and 1 for tweening
	var ease_val = ease(val, -4.6)
	for j in insight_nodes:
		j.get_child(0).position.x = 300 + ease_val * 40.0
		j.get_child(0).modulate.a = ease_val
	var scale_val = 0.9 + 0.1 * ease_val
	$SpriteCenter.scale = Vector2(scale_val, scale_val)
	$SpriteCenter/Base1.material.set_shader_parameter("alpha_scale", ease_val * 0.5)
	$SpriteCenter/Base2.material.set_shader_parameter("alpha_scale", ease_val * 1.0)
	$SpriteCenter/Base3.material.set_shader_parameter("alpha_scale", ease_val * 0.8)
	$BG.material.set_shader_parameter("state", ease_val)
	
	for c in line_nodes:
		c.modulate.a = ease_val * 0.7
		c.position.x = 230.0 + (1.0 - ease_val) * 100.0

func populate():
	for i in Global.insights_total:
		var i_container = Node2D.new()
		i_container.rotation_degrees = 360.0 / Global.insights_total * i - 90.0
		$SpriteCenter.add_child(i_container)
		insight_nodes.append(i_container)
		
		var i_sprite = Sprite2D.new()
		i_sprite.scale = Vector2(0.55, 0.55)
		i_sprite.texture = INODE
		i_container.add_child(i_sprite)
		
		for j in insight_nodes:
			j.get_child(0).rotation_degrees = - j.rotation_degrees

func update_completed_nodes():
	for c in completed_nodes: c.queue_free()
	for l in line_nodes: l.queue_free()
	completed_nodes = []
	line_nodes = []
	for c in Global.insights_collected:
		var comp_node = InsightFlame.instantiate()
		insight_nodes[c].get_child(0).add_child(comp_node)
		completed_nodes.append(comp_node)
		
		var blur = Sprite2D.new()
		blur.texture = BLUR
		insight_nodes[c].add_child(blur)
		blur.position = Vector2(230, 0)
		blur.scale = Vector2(2.0, 0.07)
		blur.z_index = -1
		line_nodes.append(blur)

func open():
	is_open = true
	primed = false
	visible = true

	$OpenSound.play()
	$OpenDelay.start()
	update_completed_nodes()
	Global.smoke_faded.emit("in")
	for c in completed_nodes: c.open()
	
	var trans_tween = create_tween()
	trans_tween.tween_method(_set_trans_state, 0.0, 1.0, 0.4)
	
	# TODO: janky; might need improving
	await get_tree().create_timer(0.1).timeout
	Action.in_insight_dialogue = false

func close():
	if can_close == false: return
	can_close = false
	is_open = false
	Global.smoke_faded.emit("out")
	Global.can_move = true
	
	var trans_tween = create_tween()
	trans_tween.tween_method(_set_trans_state, 1.0, 0.0, 0.25)
	trans_tween.tween_callback(func():
		if is_open == false: visible = false)

func play_after_dialogue(get_dialogue_data):
	primed = true
	Global.dialogue_played.emit({
		"title": "Insight",
		"data": get_dialogue_data,
		"character": ""})

func _ready():
	mouse_pos = get_viewport().get_mouse_position()
	center = get_viewport().size
	visible = false
	
	Global.insights_counted.connect(populate)
	
	# Will play dialogue first if there is any, or will skip it and go
	# straight to the insight if the array is empty (default behaviour)
	Global.insight_pane_opened.connect(func(dialogue_data):
		if !is_open:
			if dialogue_data == []:
				Action.in_insight_dialogue = true
				open()
			else: play_after_dialogue(dialogue_data))
	Global.dialogue_closed.connect(func(): if primed == true: open())
	Global.insight_pane_closed.connect(func(): if is_open: close())

func _input(_event):
	if Input.is_action_just_pressed("right_click") or Input.is_action_just_pressed("interact"):
		if is_open == true and !Action.in_insight_dialogue:
			Action.deactivate()
			Global.insight_pane_closed.emit()

func _process(_delta):
	mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos == null: return
	
	var adj = Vector2(
		clamp(2.0 * mouse_pos.x / center.x - 1.0, -1.0, 1.0) + (get_window().content_scale_factor - 1.0) * 0.5,
		clamp(2.0 * mouse_pos.y / center.y - 1.0, -1.0, 1.0) + (get_window().content_scale_factor - 1.0) * 0.5)
	$SpriteCenter.set_pos(adj * 20.0 + Vector2(0.0, -20.0), 0.055)

	var count = 0
	for j in insight_nodes:
		j.position = lerp(j.position, adj * 40.0, RANDOM[count])
		count += 1
	$SpriteCenter/Base2.position = adj * 30.0
	$SpriteCenter/Base2.rotation_degrees -= 0.12
	$SpriteCenter/Base3.rotation_degrees -= 0.07

func _on_open_delay_timeout(): can_close = true
