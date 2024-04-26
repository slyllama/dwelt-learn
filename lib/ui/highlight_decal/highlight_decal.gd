extends Decal

@export var debug_only = false

func _ready():
	Global.debug_toggled.connect(func(): visible = Global.debug_state)
