extends Control

var bus_index

var analyzer: AudioEffectSpectrumAnalyzerInstance
var samples: Array[float] = []

var amplifier_effect : AudioEffectAmplify
var amplifier_input_gain : float = 0.0

var compressor_effect : AudioEffectCompressor
var compressor_threshold : float = -12.0 # Compression threshold in dB
var compressor_ratio : float = 2.0 # Compression ratio in dB
var compressor_attack_time : float = 5000.0 # Attack time in MICROseconds
var compressor_release_time : float = 300.0 # Release time in MILLIseconds
var compressor_makeup_gain : float = 9.0 # Makeup gain that get's add to the compressor output signal

const SCALE_RATIO = 1.1
const MAX_SAMPLES = 20

@onready var menu = %Menu
@onready var input_gain_slider = %InputGainSlider

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
	
	init_amplifier(bus_index,amplifier_input_gain)
	init_compressor(bus_index)
	
	input_gain_slider.connect("value_changed",_on_input_gain_change)

func _process(_delta):
	var current_db = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)
	var magnitude = db_to_linear(current_db)
	$Menu/PanelContainer/VBoxContainer/CurrentGainLabel.text = str(snapped(current_db,1.0))
	
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
	var mag_avg: float = 0.0
	for i in samples:
		mag_sum += i
	mag_avg = mag_sum / float(samples.size())
	#$Menu/PanelContainer/VBoxContainer/CurrentGainLabel.text = str(mag_avg)
	return mag_avg
	
	
func init_amplifier(_bus_index : int, _input_gain : float = 0.0):
	amplifier_effect = AudioEffectAmplify.new()
	amplifier_effect.volume_db = _input_gain
	AudioServer.add_bus_effect(_bus_index,amplifier_effect,1)
	print("Amplifier effect initialized")
	
func init_compressor(_bus_index : int):
	compressor_effect = AudioEffectCompressor.new()
	compressor_effect.threshold = compressor_threshold
	compressor_effect.attack_us = compressor_attack_time
	compressor_effect.release_ms = compressor_release_time
	compressor_effect.gain = compressor_makeup_gain
	AudioServer.add_bus_effect(_bus_index,compressor_effect,2)
	print("Compressor effect initialized")
	
func update_amplifier(_new_input_gain : float):
	if _new_input_gain <= -10.0 || _new_input_gain >= 24.1:
		printt("Input gain out of range:",_new_input_gain)
		return
	if amplifier_effect.volume_db != _new_input_gain:
		amplifier_effect.volume_db = _new_input_gain
		printt("set amplify gain to:",_new_input_gain)


func _on_v_slider_drag_ended(value_changed):
	Save.threshold = value_changed

func _on_gui_input(event):
	if event is InputEventMouseButton and menu.drag_target:
		if is_instance_valid(menu.drag_target):
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					menu.drag_target.user_scale *= SCALE_RATIO
				MOUSE_BUTTON_WHEEL_DOWN:
					menu.drag_target.user_scale *= 1 / SCALE_RATIO
	
# Not necessary bur could be useful in the future 
func _on_input_gain_change(_new_input_gain : float):
	update_amplifier(_new_input_gain)
