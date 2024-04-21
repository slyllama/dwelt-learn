extends Node3D

func _fov_changed():
	%Player/CamPivot/CamArm/Camera.fov = Global.fov

func _mute_changed():
	AudioServer.set_bus_mute(0, Global.mute)

func _blend_shadow_splits():
	$Sun.directional_shadow_blend_splits = Global.blend_shadow_splits

func _ready():	
	# Apply settings and connect global changes
	Global.connect("fov_changed", _fov_changed)
	Global.emit_signal("fov_changed")
	Global.connect("mute_changed", _mute_changed)
	Global.emit_signal("mute_changed")
	Global.connect("blend_shadow_splits_changed", _blend_shadow_splits)
	Global.emit_signal("blend_shadow_splits_changed")
	
	$Ambience.volume_db = -20.0
	var ambi_tween = create_tween()
	ambi_tween.tween_property($Ambience, "volume_db", -3.0, 2.0).set_trans(Tween.TRANS_EXPO)
	await get_tree().create_timer(4.0).timeout
	$Music.play()
