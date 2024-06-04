extends "res://lib/world_loader/world_loader.gd"

func _ready():
	interact_objects = [ $Insights/Insight, $Insights/Insight2 ]
	super()
	Global.debug_state = true
	Global.debug_toggled.emit()

	proc_save() # trigger save loading now that customs have been added

func _input(_event):
	super(_event)
	if Input.is_action_just_pressed("debug_action"):
		$HUD/SettingsTabs.open()
