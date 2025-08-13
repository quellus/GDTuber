extends Node

#Audio
const MAX_SAMPLES = 20

const THRESHOLD_DEFAULT: float = 0.5
const INPUT_GAIN_DEFAULT: float = 0.0

#Audio Vars
var bus_index
var analyzer: AudioEffectSpectrumAnalyzerInstance
var samples: Array[float] = []
var amplifier_effect = AudioEffectAmplify
var threshold = 0.5
var input_gain: float
var input_device: String
var mag_throbber_value:= 0.0 # maybe should be capitalized as a read value? 

# UI should be subscribeing to events 
# that animate this? I guess? 

func _ready() -> void:
    bus_index = AudioServer.get_bus_index("Record")
    amplifier_effect = AudioServer.get_bus_effect(bus_index, 1)

func get_audio_devices() -> PackedStringArray: 
    return  AudioServer.get_input_device_list()

func _get_average() -> float:
    var mag_sum: float = 0.0
    var mag_avg: float = 0.0
    for i in samples:
        mag_sum += i
    mag_avg = mag_sum / float(samples.size())
    return mag_avg

func _process(_delta: float) -> void:
    # Audio Processing
    var current_db = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)
    var magnitude = db_to_linear(current_db)

    if samples.size() >= MAX_SAMPLES:
        samples.pop_front()
    samples.append(magnitude)
    
    var magnitude_avg = _get_average() 
    mag_throbber_value = magnitude_avg

func set_input_source(new_input_device) -> void:
    AudioServer.set_input_device(new_input_device)
    input_device = new_input_device

func get_audio_config() -> Array:
    return [input_device, threshold, input_gain]

func set_audio_config(set_input_device, set_threshold, set_input_gain_value) -> void:
    threshold = set_threshold
    set_input_gain(set_input_gain_value)
    set_input_source(set_input_device)
    

func set_input_gain(new_input_gain: float) -> void:
    _update_amplifier(new_input_gain)
    input_gain = new_input_gain


func _update_amplifier(new_input_gain: float):
    if new_input_gain <= -10.0 || new_input_gain >= 24.1:
        return
    if amplifier_effect.volume_db != new_input_gain:
        amplifier_effect.volume_db = new_input_gain


func audio_reset() -> void:
    print_debug("Resetting audio device")
    var orig_device = AudioServer.input_device
    var devices = AudioServer.get_input_device_list()
    var index = devices.find(orig_device)
    var rand_index = (index + randi_range(1, devices.size() - 1)) % devices.size()
    AudioServer.input_device = devices[rand_index]
    await get_tree().create_timer(0.2).timeout
    AudioServer.input_device = orig_device
