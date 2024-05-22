extends Panel

@export var title: String = "Input Hint"
@export var description: String = "Input hint description."
@export var key_text: String = "#"

func _ready():
	$Title.text = str(title).to_upper()
	$Description.text = description
	$Panel/Key.text = Utilities.cntr(str(key_text).to_upper())
