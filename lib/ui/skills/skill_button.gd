extends TextureButton

## Whether the skill can be used.
@export var enabled = true
## Passed to the 'Global.skill_clicked' signal and listened to by others.
@export var skill_name = "empty"

func enable():
	enabled = true
	$Icon.modulate = Color(1.0, 1.0, 1.0)

func disable():
	enabled = false
	self_modulate.a = 0.5
	$Icon.modulate = Color(0.35, 0.35, 0.35)

func _ready():
	disable() # disabled by default
	self_modulate.a = 0.5

func _mouse_entered():
	if enabled == false: return
	Global.button_hover.emit()
	self_modulate.a = 1.0

func _mouse_left():
	self_modulate.a = 0.5

func _on_pressed():
	if enabled == false: return
	Global.skill_clicked.emit(skill_name)
