@tool
extends VBoxContainer

@export var setting_id: String
@export var setting_title = "[Setting]"
@export var show_output = true
@export var output_as_percentage = false
@export var output_suffix = ""

@export_category("Slider Settings")
@export var min_value: float = 0
@export var max_value: float = 100
@export var step: float = 1

var is_slider = true

var in_focus = false

func fstr(num, place = 0.01): # copied from Utilities for @tool
	return(str(snapped(num, place)))

func update_title(override_value = -999):
	if show_output == false: return
	var new_value
	if override_value == -999: new_value = float($Slider.value)
	else: new_value = override_value
	
	var disp: String
	if output_as_percentage == true:
		disp = str(snapped(new_value * 100, 1))
	else: disp = fstr(new_value)
	
	$Title.text = (str(setting_title) + ": " + disp + output_suffix)
	if output_as_percentage == true: $Title.text += "%"

func _ready():
	$Slider.min_value = min_value
	$Slider.max_value = max_value
	$Slider.step = step
	
	if output_suffix == "deg": output_suffix = "\u00B0"
	$Title.text = str(setting_title)
	
	if Engine.is_editor_hint() == true: return
	
	Global.setting_changed.connect(func(get_setting_id):
		if get_setting_id == setting_id and setting_id != null:
			$Slider.value = Global.settings[setting_id]
			update_title())

func _on_slider_drag_started():
	Global.dragging_control = true

func _on_slider_drag_ended(_value_changed):
	Global.dragging_control = false
	Global.settings[setting_id] = $Slider.value
	Global.setting_changed.emit(setting_id)

func _on_slider_value_changed(value):
	update_title(value)
	if in_focus:
		Global.settings[setting_id] = $Slider.value
		Global.setting_changed.emit(setting_id)

func _on_slider_focus_entered():
	in_focus = true
	Global.button_hover.emit()

func _on_slider_focus_exited():
	in_focus = false
