extends CanvasLayer

const HintCard = preload("res://lib/ui/input_hints/hint_card.tscn")
var card_data = [
	{ "title": "INTERACT", "description": "Look at a nearby curiosity.", "key": "F" },
	{ "title": "GLIDE", "description": "Soar in updrafts; hover while descending.", "key": "E" } ]
var card_nodes = []
var transitioning = false
var active = false

func clear_hints():
	for c in card_nodes.size():
		var cn = card_nodes[card_nodes.size() - 1 -c] # reverse
		if active == false:
			cn.fade_out(false)
			await get_tree().create_timer(0.3).timeout

# If clear_time is 0, the hints will remain until cleared by clear_hints()
func show_hints(get_card_data, clear_time = 0.0):
	$ClearTimer.stop()
	active = true
	$Container.modulate.a = 1.0
	for c in card_nodes: c.queue_free()
	card_nodes = []
	
	for card in get_card_data:
		var card_node = HintCard.instantiate()
		
		card_node.title = card["title"]
		card_node.description = card["description"]
		card_node.key_text = card["key"]
		$Container.add_child(card_node)
		
		card_nodes.append(card_node)
		await get_tree().create_timer(0.1).timeout
	
	if clear_time > 0.0:
		$ClearTimer.set_wait_time(clear_time)
		$ClearTimer.start()

func _input(_event):
	if Input.is_action_just_pressed("debug_action"):
		show_hints(card_data, 2.0)

func _on_clear_timer_timeout():
	active = false
	clear_hints()
