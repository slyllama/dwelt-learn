extends CanvasLayer

var ip = 0.0

func _process(_delta):
	if !Global.insight_on_map:
		if $Pos.visible: $Pos.visible = false
		return
	else: $Pos.visible = true
	
	if Global.insight_visible:
		ip = Global.insight_camera_position.x
	ip = clamp(ip, 50.0, Global.SCREEN_SIZE.x - 50.0)
	$Pos.position.x = lerp($Pos.position.x, ip, 0.5)
