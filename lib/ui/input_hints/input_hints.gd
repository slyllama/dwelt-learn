extends CanvasLayer

const HintCard = preload("res://lib/ui/input_hints/hint_card.tscn")
var card_nodes = []
var transitioning = false
var active = false

# { "data": Array, "clear_time": float }
var buffered_data = {}
var buffered_close = false

func clear_hints():
	if !buffered_close: return # for late events
	active = false
	buffered_close = false
	
	for c in card_nodes.size():
		var cn = card_nodes[card_nodes.size() - 1 -c] # reverse
		if active == false:
			cn.fade_out(false)
			await get_tree().create_timer(0.3).timeout

# If clear_time is 0, the hints will remain until cleared by clear_hints()
func show_hints(get_card_data, clear_time = 0.0):
	active = true
	
	$ClearTimer.stop()
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
	
	if clear_time > 0.0:
		$ClearTimer.set_wait_time(clear_time)
		$ClearTimer.start()
	
	buffered_data = {}

func _ready():
	Global.input_hint_played.connect(func(get_data, get_clear_time):
		buffered_data = { "data": get_data, "clear_time": get_clear_time }
	)
	Global.input_hint_cleared.connect(func():
		buffered_close = true
	)

func _on_clear_timer_timeout():
	buffered_close = true

var b = false

func _buffer_process():
	b = !b
	if buffered_close and active and b:
		clear_hints()
		return
	if buffered_data != {} and !active:
		show_hints(buffered_data.data, buffered_data.clear_time)
