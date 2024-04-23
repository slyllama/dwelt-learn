extends Node3D

var adj_mouse_pos = Vector2.ZERO # given with (0.0, 0.0) as the middle of the screen

func _ready():
	if DisplayServer.screen_get_size().x > 2000:
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(load("res://generic/tex/cursor_2x.png"))
	
	# Run music and effects
	$FX.volume_db = -40.0
	$FX.play()
	var fade_fx_in = create_tween()
	fade_fx_in.tween_property($FX, "volume_db", -5.0, 3.0).set_trans(Tween.TRANS_EXPO)
	await get_tree().create_timer(2.0).timeout
	$Music.play()

func _process(_delta):
	adj_mouse_pos.x = get_window().get_mouse_position().x / Global.SCREEN_SIZE.x - 0.5
	adj_mouse_pos.y = get_window().get_mouse_position().y / Global.SCREEN_SIZE.y - 0.5
	
	if (adj_mouse_pos.x > -1 and adj_mouse_pos.x < 1
		and adj_mouse_pos.y > -1 and adj_mouse_pos.y < 1):
		$Camera3D.position.x = lerp($Camera3D.position.x, 0.6 * adj_mouse_pos.x, 0.05)
		$Camera3D.position.y = lerp($Camera3D.position.y, -0.6 * adj_mouse_pos.y, 0.05)
