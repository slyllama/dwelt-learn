extends CanvasLayer

func fade_in():
	$BG.modulate.a = 1.0
	var fade_tween = create_tween()
	fade_tween.tween_property($BG, "modulate:a", 0.0,0.4)

func _ready():
	visible = true
