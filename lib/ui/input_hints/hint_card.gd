extends Panel

@export var title: String = "Input Hint"
@export var description: String = "Input hint description."
@export var key_text: String = "#"

func _set_trans(val):
	modulate.a = val
	self_modulate = Color(1.0 - val, 1.0 - val, 1.0 - val, 1.0)

func _ready():
	modulate.a = 1.0
	self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	$Title.text = str(title).to_upper()
	$Description.text = description
	$Panel/Key.text = Utilities.cntr(str(key_text).to_upper())
	
	var fade = create_tween()
	fade.tween_method(_set_trans, 0.0, 1.0, 0.2)
