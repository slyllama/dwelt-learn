extends AudioStreamPlayer
# Catches UI mouseover elements using the Global.button_hover signal and plays
# a little sound. Only include one in each scene to avoid double-ups.

func _ready():
	Global.button_hover.connect(func(): play())
