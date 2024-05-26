extends Node3D
# ping_nodule.gd
# Will appear and animate above nearby Insights (as called by WorldLoader),
# disappearing again after a certain time.

func _ready():
	$RemoveTimer.start()

func _on_remove_timer_timeout():
	queue_free()
