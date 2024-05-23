extends CanvasLayer
# skills_bar.gd - the skills bar presents skills at the bottom of the screen,
# and is parented to the HUD. By default it only shows an 'interact' skill
# (which is rendered as disabled when there is nothing to interact with), but
# additional skills that are learnt around the Lattice, such as gliding, will
# appear here. They should show the relevant input key.

func _ready():
	Action.untargeted.connect(func():
		if Action.active == false:
			$HBox/Interact.disable())
	Action.targeted.connect($HBox/Interact.enable)
	Action.activated.connect(func(can_toggle):
		if can_toggle == true:
			$HBox/Interact.enable()
			$HBox/Interact.set_texture("CANCEL")
		else: $HBox/Interact.disable())
	Action.deactivated.connect(func():
		$HBox/Interact.disable()
		$HBox/Interact.set_texture("INTERACT"))
	
	$HBox/Glide.enable()
	$HBox/Ping.enable()

# Interact skill overrides
func _on_interact_pressed(): if Action.active == true: pass

# Glide skill overrides
func _on_glide_pressed(): Action.glide_pressed.emit()
func _on_glide_button_down(): Action.in_glide = true
func _on_glide_button_up(): Action.in_glide = false
func _on_ping_pressed(): Global.ping.emit()
