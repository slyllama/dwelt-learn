extends "res://lib/world_loader/world_loader.gd"

func _n(): return

func _set_lever_text():
	if $LeverA.state: $LeverA/AVis.set_text("Lever A\n[color=green]ON[/color]")
	else: $LeverA/AVis.set_text("Lever A\n[color=yellow]OFF[/color]")
	if $LeverB.state: $LeverB/BVis.set_text("Lever B\n[color=green]ON[/color]")
	else: $LeverB/BVis.set_text("Lever B\n[color=yellow]OFF[/color]")

func _ready():
	interact_objects = [ $Insights/Insight, $Insights/Insight2, $LeverA, $LeverB, $LeverJedi ]
	super()
	$LeverJedi/AnimationPlayer.play("Idle")
	Global.debug_state = true
	Global.debug_toggled.emit()

	Save.save_loaded.connect(func():
		var lever_a_state = Save.get_data(map_name, "lever_a_state")
		$LeverA.set_state(lever_a_state) if lever_a_state else _n()
		var lever_b_state = Save.get_data(map_name, "lever_b_state")
		$LeverB.set_state(lever_b_state) if lever_b_state else _n()
	)
	proc_save() # trigger save loading now that customs have been added
	_set_lever_text()

func _on_lever_a_state_set(state):
	Save.set_data(map_name, "lever_a_state", state)
	_set_lever_text()
func _on_lever_b_state_set(state):
	Save.set_data(map_name, "lever_b_state", state)
	_set_lever_text()
