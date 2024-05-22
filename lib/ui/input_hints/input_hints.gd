extends CanvasLayer

const HintCard = preload("res://lib/ui/input_hints/hint_card.tscn")
var card_data = [
	{ "title": "1", "description": "1 description.", "key": "1" },
	{ "title": "2", "description": "2 description.", "key": "2" } ]
var card_nodes = []
var transitioning = false
var active = false

func clear_hints():
	var fade = create_tween()
	fade.tween_property($Container, "modulate:a", 0.0, 0.2)

# If clear_time is 0, the hints will remain until cleared by clear_hints()
func show_hints(get_card_data, clear_time = 0.0):
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
	clear_hints()
