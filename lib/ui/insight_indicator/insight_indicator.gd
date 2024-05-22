extends CanvasLayer

var line_size = 1920.0
var diff = 0.0

func _ready():
	line_size = $Line.size.x
	diff = (Global.SCREEN_SIZE.x - line_size) / 2.0

func _physics_process(_delta):
	if !Global.insight_on_map:
		if $Pos.visible: $Pos.visible = false
		return
	else: $Pos.visible = true
	
	var ip = Global.insight_camera_position.x
	if ip > 0 and ip < Global.SCREEN_SIZE.x and Global.insight_visible:
		#$Pos.position.x = clamp(
			#ip, diff, Global.SCREEN_SIZE.x - diff)
		var ip_clamp = clamp(ip, diff, Global.SCREEN_SIZE.x - diff)
		$Pos.position.x = lerp($Pos.position.x, ip_clamp, 0.5)
