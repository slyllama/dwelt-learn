extends TextureButton

## Whether the skill can be used.
@export var enabled = true
## Passed to the 'Global.skill_clicked' signal and listened to by others.
@export var skill_name = "empty"

func enable():
	enabled = true
	modulate = Color(1.0, 1.0, 1.0)

func disable():
	enabled = false
	self_modulate.a = 0.5
	modulate = Color(0.3, 0.3, 0.3)

func _ready():
	Global.interact_left.connect(disable)
	Global.interact_entered.connect(enable)
	disable()

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
