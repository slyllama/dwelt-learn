@tool
class_name VersionText extends RichTextLabel

func _ready():
	text = "[right]" + str(Global.VERSION) + "[/right]"
