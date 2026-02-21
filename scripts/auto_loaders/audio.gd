# Math based on what I read in this article 
# https://blog.truegeometry.com/tutorials/education/2739c141c0ddf9b1a1ee2c4d75f2d3c4/JSON_TO_ARTCL_RMS_vs_Peak_to_Peak_in_Audio_Applications_in_context_of_rms_to_pea.html

extends Node

#Audio
const THRESHOLD_DEFAULT: float = 0.5
const INPUT_GAIN_DEFAULT: float = 0.0

var min_db: float = -30.0
var noise_floor: float = 0.02
var throb_rise_speed: float = 80.0
var throb_release_speed: float = 3.5
var bus_index
var amplifier_effect = AudioEffectAmplify
var threshold = 0.5
var input_gain: float
var input_device: String
var mag_throbber_value:= 0.0
var smoothed:= 0.0

# Grabbed formula for sample size from 
# https://github.com/goatchurchprime/godot-demo-projects/blob/gtch/mic_input/audio/mic_input/MicRecord.gd
@onready var input_mix_rate: int = int(AudioServer.get_input_mix_rate())
var audio_chunk_time: float = 0.02
@onready var audio_sample_size: int = int(input_mix_rate * audio_chunk_time + 0.5)

func _ready() -> void:
    bus_index = AudioServer.get_bus_index("Record")
    amplifier_effect = AudioServer.get_bus_effect(bus_index, 1)

func get_audio_devices() -> PackedStringArray: 
    return  AudioServer.get_input_device_list()

func _process(_delta: float) -> void:
    # Audio Processing using RMS from raw audio frames 
    var sample_frame_totals: float = 0.0
    var total_samples = 0
    

    while AudioServer.get_input_frames_available() >= audio_sample_size:
        var audio_samples: PackedVector2Array = AudioServer.get_input_frames(audio_sample_size)

        if not audio_samples:
            return
        total_samples += audio_samples.size()

        for sample_frames in audio_samples:
            # square sum of left and right channels 
            sample_frame_totals += sample_frames.x * sample_frames.x
            sample_frame_totals += sample_frames.y * sample_frames.y

    if total_samples > 0:
        # root median squared, for loudness 
        var rms_sample_average = sqrt(sample_frame_totals/ float(total_samples))

        # Scaling by input gain: 
        # I though this should be 12 since our scale is 1-24
        # but then the db is like half what it should be.  
        rms_sample_average *= input_gain/6.0

        # Convert to human loudness perception ie. decibels 
        var db = linear_to_db(rms_sample_average)
        
        # Display range is 0.0-1.0 clamp to that range
        var display_average = inverse_lerp(min_db, 0.0, db)
        display_average = clamp(display_average, 0.0, 1.0)

        # Smooth with lerping math: 
        # https://lisyarus.github.io/blog/posts/exponential-smoothing.html
        var speed = throb_rise_speed if display_average > smoothed else throb_release_speed
        var lerp_factor = 1.0 - pow(0.1, _delta * speed)
        smoothed = lerp(smoothed, display_average, 1.0 - exp(-speed * lerp_factor))

        mag_throbber_value = smoothed

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
