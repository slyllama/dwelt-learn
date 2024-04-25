extends CanvasLayer
# "Anime" effect which shows when the player moves

@export var time = 0.5
@export var maximum_alpha = 0.065

var active = false

func anime_in():
	active = true
	$AnimeTex.modulate.a = 0.0
	$AnimeTex.visible = true
	var fade_tween = create_tween()
	fade_tween.tween_property($AnimeTex, "modulate:a", maximum_alpha, time)

func anime_out():
	active = true
	$AnimeTex.modulate.a = maximum_alpha
	var fade_tween = create_tween()
	fade_tween.tween_property($AnimeTex, "modulate:a", 0.0, time / 3.0)
	fade_tween.tween_callback(func():
		if active == true:
			return
		visible = false)

func _ready():
	$AnimeTex.modulate.a = 0.0
	$AnimeTex.visible = false
