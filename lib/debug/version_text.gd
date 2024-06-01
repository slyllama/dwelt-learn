@tool
class_name VersionText extends RichTextLabel

func _ready():
	add_theme_font_override("normal_font", load("res://generic/fonts/red_hat.ttf"))
	text = "[right]" + str(Global.VERSION).to_upper() + "[/right]"
