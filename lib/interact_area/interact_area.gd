extends Area3D

@export var TYPE = "ignore"
@export var debug_messages = true
var dp = "[InteractArea '" + str(TYPE) + "']" # debug prefix
var active = false
var in_area = false

signal activated
signal deactivated

func pdebug(msg):
	if debug_messages == true: 
		print("[InteractArea '" + str(TYPE) + "'] " + str(msg))

func deactivate():
	active = false
	deactivated.emit()
	Global.in_action = false

func _ready():
	Global.dialogue_closed.connect(deactivate)

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		if Global.in_area_name != TYPE: return
		# TODO: come up with a more elegant way to handle this dialogue_active thing?
		if (in_area == false or Global.in_keybind_select == true
			or Global.dialogue_active == true):
			return
		if active == false and Global.in_action != true:
			pdebug("Activating area.")
			active = true
			activated.emit()
			Global.in_action = true
			Global.interact_left.emit() # hide overlay
			return
		else: deactivate()

func _process(_delta):
	if Global.in_area_name != TYPE: 
		if in_area == true:
			if active == true:
				pdebug("Area was active, so deactivating.")
				deactivate()
			in_area = false
			return
	else: if in_area == false:
		pdebug("Entering area.")
		in_area = true
