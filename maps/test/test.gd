extends "res://lib/world_loader/world_loader.gd"

func _n(): return

func _ready():
	interact_objects = [ $Insights/Insight, $Insights/Insight2, $LeverA, $LeverB, $LeverJedi ]
	super()
	$LeverJedi/AnimationPlayer.play("Idle")

	Save.save_loaded.connect(func():
		var lever_a_state = Save.get_data(map_name, "lever_a_state")
		$LeverA.set_state(lever_a_state) if lever_a_state else _n()
		var lever_b_state = Save.get_data(map_name, "lever_b_state")
		$LeverB.set_state(lever_b_state) if lever_b_state else _n()
	)
	proc_save() # trigger save loading now that customs have been added

func _input(_event):
	super(_event)
	if Input.is_action_just_pressed("debug_action"):
		Global.printc(Save.save_data)

func _on_lever_a_state_set(state):
	Save.set_data(map_name, "lever_a_state", state)

func _on_lever_b_state_set(state):
	Save.set_data(map_name, "lever_b_state", state)
