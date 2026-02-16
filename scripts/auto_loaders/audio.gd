extends Node

#Audio
const MAX_SAMPLES = 20

const THRESHOLD_DEFAULT: float = 0.5
const INPUT_GAIN_DEFAULT: float = 0.0

const AUDIO_REST_TIMEOUT = 60

@export var min_db: float = -60.0
@export var noise_floor: float = 0.02
@export var throb_speed: float = 20.0
@export var release_speed: float = 6.0

#Audio Vars
var bus_index
var analyzer: AudioEffectSpectrumAnalyzerInstance
var samples: Array[float] = []
var amplifier_effect = AudioEffectAmplify
var threshold = 0.5
var input_gain: float
var input_device: String
var mag_throbber_value:= 0.0
var mag_throbber_value_sample:= 0.0
# var _microphone_reset_timer := Timer.new()

@onready var input_mix_rate: int = int(AudioServer.get_input_mix_rate())
var audio_chunk_time: float = 0.02
@onready var audio_sample_size: int = int(input_mix_rate * audio_chunk_time + 0.5)

func _ready() -> void:
    bus_index = AudioServer.get_bus_index("Record")
    amplifier_effect = AudioServer.get_bus_effect(bus_index, 1)

    # _microphone_reset_timer.wait_time=AUDIO_REST_TIMEOUT
    # _microphone_reset_timer.timeout.connect(self.audio_reset)
    # _microphone_reset_timer.autostart=true
    # add_child(_microphone_reset_timer)

func get_audio_devices() -> PackedStringArray: 
    return  AudioServer.get_input_device_list()

func _get_average() -> float:
    var mag_sum: float = 0.0
    var mag_avg: float = 0.0
    for i in samples:
        mag_sum += i
    mag_avg = mag_sum / float(samples.size())
    return mag_avg

func new_process(_delta: float) -> void:
    print("------New Audio--------")
    # Audio Processing
    var left_sample_frame_totals: float = 0.0
    var total_samples = 0
    var smoothed: float = 0.0


    while AudioServer.get_input_frames_available() >= MAX_SAMPLES:
        var audio_samples: PackedVector2Array = AudioServer.get_input_frames(MAX_SAMPLES)

        if not audio_samples:
            return
        total_samples += audio_samples.size()
        # print("audio Sample size:",  total_samples)

        for sample_frames in audio_samples:
            var s = sample_frames.x
            left_sample_frame_totals += s * s

    if total_samples > 0:
        # root median squared, for smoother numbers 
        var rms_sample_average = sqrt(left_sample_frame_totals/ float(total_samples))

        rms_sample_average *= input_gain/6.0
        var db = linear_to_db(rms_sample_average)
        
        var display_average = inverse_lerp(min_db, 0.0, db)
        display_average = clamp(display_average, 0.0, 1.0)

        mag_throbber_value_sample = display_average 


        print("current Gain ", input_gain)
        print("new throbber: ", mag_throbber_value_sample)

        

        #var display_average = clamp((db - min_db) / -min_db, 0.0, 1.0)
        #display_average = clamp(display_average, 0.0, 1.0)
#
        #if display_average < noise_floor:
        #    display_average = 0.0
        #
        #var speed = throb_speed if display_average > smoothed else release_speed
        #smoothed = lerp(smoothed, display_average, 1.0 - exp(-speed * _delta))
#
        #mag_throbber_value_sample = smoothed * 2 
        

        # print("New Throbber: ", display_average) # should be left


func _process(_delta: float) -> void:
    print("--------Old Audio----------")
    # Audio Processing
    var current_db = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)
    # print("left Bus db: ", current_db)
    var magnitude = db_to_linear(current_db)
    # print("magnitude: ", magnitude)

    if samples.size() >= MAX_SAMPLES:
        samples.pop_front()
        # print("sample pop:", )
    samples.append(magnitude)
    
    var magnitude_avg = _get_average() 
    mag_throbber_value = magnitude_avg
    
    print("Old Throbber: ", magnitude_avg)
    
    new_process(_delta)

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
