extends Control

var analyzer: AudioEffectSpectrumAnalyzerInstance
var samples: Array[float] = []
const MAX_SAMPLES = 20
var threshold := 0.5

@onready var sprite = $Sprite2D

func _ready():
	var idx = AudioServer.get_bus_index("Record")
	analyzer = AudioServer.get_bus_effect_instance(idx, 0)


func _process(_delta):
	var sample = analyzer.get_magnitude_for_frequency_range(60, 500, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_AVERAGE)
	var magnitude = sample.x  * 200
	
	if samples.size() >= MAX_SAMPLES:
		samples.pop_front()
	samples.append(magnitude)
	
	var magnitude_avg = _get_average(samples)
	
	if magnitude_avg > threshold:
		if sprite.frame % 2 == 0:
			sprite.frame += 1
			print(sprite.frame)
	elif sprite.frame % 2 == 1:
		sprite.frame -= 1
		print(sprite.frame)
	
	$ProgressBar.value = magnitude_avg


func _get_average(samples: Array[float]) -> float:
	var mag_sum: float = 0.0
	for i in samples:
		mag_sum += i
	return mag_sum / float(samples.size())
	

func _on_v_slider_drag_ended(value_changed):
	threshold = $VSlider.value
	print(threshold)
