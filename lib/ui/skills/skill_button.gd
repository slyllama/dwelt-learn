extends TextureButton

## Whether the skill can be used.
@export var enabled = true
## Passed to the 'Global.skill_clicked' signal and listened to by others.
@export var skill_name = "empty"
@export var input_mapping = "none"
@export var initial_texture = "UNKNOWN"

const textures = {
	"UNKNOWN": preload("res://lib/ui/skills/tex/unknown.png"),
	"CANCEL": preload("res://lib/ui/skills/tex/cancel.png"),
	"LOCKED": preload("res://lib/ui/skills/tex/locked.png"),
	"GLIDE": preload("res://lib/ui/skills/tex/glide.png"),
	"INTERACT": preload("res://lib/ui/skills/tex/interact.png"),
	"PING": preload("res://lib/ui/skills/tex/ping.png")
}

func enable():
	enabled = true
	$Icon.modulate.a = 1.0

func disable():
	enabled = false
	self_modulate.a = 0.4
	$Icon.modulate.a = 0.2

func set_texture(tex_name):
	if !tex_name in textures: return
	$Icon.texture = textures[tex_name]

# Updates the input command that shows on the bottom right of the button
func _get_key():
	if input_mapping != "none":
		if Global.input_mode == Global.InputModes.KEYBOARD:
			$InputKey.text = Utilities.cntr(Utilities.get_key(input_mapping))
		else:
			if input_mapping in Global.CONTROLLER_KEYS:
				$InputKey.text = Utilities.cntr(Global.CONTROLLER_KEYS[input_mapping])
			else: $InputKey.text = Utilities.cntr("?")
	else: $InputKey.visible = false

func _ready():
	disable() # disabled by default
	_get_key()
	self_modulate.a = 0.4
	Global.input_changed.connect(_get_key)
	set_texture(initial_texture)
	
	Global.input_mode_switched.connect(_get_key)

func _mouse_entered():
	if !enabled: return
	self_modulate.a = 1.0

func _mouse_left(): self_modulate.a = 0.4

func _on_pressed():
	if enabled == false: return
	Global.skill_clicked.emit(skill_name)
