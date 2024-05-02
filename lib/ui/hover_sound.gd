extends AudioStreamPlayer
# Catches UI mouseover elements using the Global.button_hover signal and plays
# a little sound. Only include one in each scene to avoid double-ups.
# TODO: this now incorporates a clicking sound. Change names and structure so
# this makes more sense

func _ready():
	Global.button_hover.connect(func(): play())
	Global.button_click.connect(func(): $UIClick.play())
