extends "res://lib/world_loader/world_loader.gd"

func _ready():
	$Buttons/WarpButton.modulate.a = 0.0
	super()
	
	%Player.set_model_scale(0.2)
	
	await get_tree().create_timer(1.2).timeout
	var fade_tween = create_tween()
	fade_tween.tween_property($Buttons/WarpButton, "modulate:a", 1.0, 0.5)

func _on_warp_button_pressed():
	Global.current_map = "test_room"
	get_tree().change_scene_to_file("res://lib/loading/loading.tscn")
