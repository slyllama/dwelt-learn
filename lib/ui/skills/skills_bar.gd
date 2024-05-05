extends CanvasLayer
# skills_bar.gd - the skills bar presents skills at the bottom of the screen,
# and is parented to the HUD. By default it only shows an 'interact' skill
# (which is rendered as disabled when there is nothing to interact with), but
# additional skills that are learnt around the Lattice, such as gliding, will
# appear here. They should show the relevant input key.

func _ready():
	Global.interact_left.connect(func():
		if Global.in_action == false:
			$HBox/Interact.disable())
	Global.interact_entered.connect($HBox/Interact.enable)
	Global.action_entered.connect(func(can_toggle):
		if can_toggle == true:
			$HBox/Interact.enable()
			$HBox/Interact.set_texture("CANCEL")
		else: $HBox/Interact.disable())
	Global.action_left.connect(func():
		$HBox/Interact.disable()
		$HBox/Interact.set_texture("UNKNOWN"))

func _on_interact_pressed():
	if Global.in_action == true: pass
