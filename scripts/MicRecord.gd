extends Control

var analyzer: AudioEffectSpectrumAnalyzerInstance
var samples: Array[float] = []
const MAX_SAMPLES = 10
var bus_index
@onready var menu = %Menu

const SCALE_RATIO = 1.1


var is_talking := false:
	set(value):
		if value != is_talking:
			for screen_object in get_tree().get_nodes_in_group("reactive"):
				if screen_object is ScreenObject:
					screen_object.is_talking = value
		is_talking = value

func _ready():
	get_tree().get_root().set_transparent_background(true)
	bus_index = AudioServer.get_bus_index("Record")

func _process(_delta):
	var magnitude = db_to_linear(AudioServer.get_bus_peak_volume_left_db(bus_index, 0))
	
	if samples.size() >= MAX_SAMPLES:
		samples.pop_front()
	samples.append(magnitude)
	
	var magnitude_avg = _get_average()

	if magnitude_avg > Save.threshold:
		if !is_talking:
			is_talking = true
	else:
		if is_talking:
			is_talking = false

	%VolumeVisual.value = magnitude_avg

func _unhandled_input(event):
	if event is InputEventKey or event is InputEventMouse:
		if event.is_pressed():
			menu.menu_shown = true
		

func _get_average() -> float:
	var mag_sum: float = 0.0
	for i in samples:
		mag_sum += i
	return mag_sum / float(samples.size())
	

func _on_v_slider_drag_ended(value_changed):
	Save.threshold = %ThesholdSlider.value



func _on_gui_input(event):
	if event is InputEventMouseButton and menu.drag_target:
		if is_instance_valid(menu.drag_target):
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					menu.drag_target.user_scale *= SCALE_RATIO
				MOUSE_BUTTON_WHEEL_DOWN:
					menu.drag_target.user_scale *= 1 / SCALE_RATIO
	
