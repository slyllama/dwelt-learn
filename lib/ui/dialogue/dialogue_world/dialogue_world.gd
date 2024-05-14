extends SubViewport

func _ready():
	#TODO: debug
	$"3DWorld/TestModel/AnimationPlayer".play("Idle")
	$"3DWorld/Euclid/AnimationPlayer".play("Idle")
