extends CanvasLayer

const HintCard = preload("res://lib/ui/input_hints/hint_card.tscn")
var card_nodes = []
var transitioning = false
var active = false

func clear_hints():
	if !active : return
	active = false
	
	# Old version:
	for c in card_nodes.size():
		if active == false:
			var cn = card_nodes[card_nodes.size() - 1 - c] # reverse
			if cn != null: cn.fade_out(false) # if not already freed
			await get_tree().create_timer(0.3).timeout

# If clear_time is 0, the hints will remain until cleared by clear_hints()
func show_hints(get_card_data, clear_time = 0.0):
	active = true
	await get_tree().create_timer(0.1).timeout
	$ClearTimer.stop()
	$Container.modulate.a = 1.0

	for c in card_nodes:
		if c != null: c.queue_free() # if not already freed
	card_nodes = []
	
	for card in get_card_data:
		var card_node = HintCard.instantiate()
		
		card_node.title = card["title"]
		card_node.description = card["description"]
		card_node.key_text = card["key"]
		$Container.add_child(card_node)
		card_nodes.append(card_node)
	
	if clear_time > 0.0:
		$ClearTimer.set_wait_time(clear_time)
		$ClearTimer.start()

func _ready():
	Global.input_hint_played.connect(show_hints)
	Global.input_hint_cleared.connect(clear_hints)

func _on_clear_timer_timeout():
	clear_hints()

func _on_check_timer_timeout():
	var is_interact = false
	for c in card_nodes:
		if c == null: return
		if c.title == "Interact": is_interact = true
	if is_interact and Action.target == "":
		Global.printc("[InputHints] clearing a stuck input hint.", "yellow")
		Global.input_hint_cleared.emit()
