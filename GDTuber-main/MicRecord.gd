extends Control

var analyzer: AudioEffectSpectrumAnalyzerInstance
var samples: Array[float] = []
const MAX_SAMPLES = 10
var bus_index
var is_talking = false
@onready var animator = $Control/Control/AnimationPlayer
@onready var sprite = %AvatarSprite
@onready var menu = %Menu

func _ready():
	get_tree().get_root().set_transparent_background(true)
	bus_index = AudioServer.get_bus_index("Record")

func _process(_delta):
	var magnitude = db_to_linear(AudioServer.get_bus_peak_volume_left_db(bus_index, 0))
	
	if samples.size() >= MAX_SAMPLES:
		samples.pop_front()
	samples.append(magnitude)
	
	var magnitude_avg = _get_average(samples)

	if magnitude_avg > Save.threshold:
		if !is_talking:
			is_talking = true
			if !animator.is_playing():
				animator.play("bounce")
		if sprite.frame % 2 == 0:
			sprite.frame += 1
	else:
		if is_talking:
			is_talking = false
		if sprite.frame % 2 == 1:
			sprite.frame -= 1

	%VolumeVisual.value = magnitude_avg

func _unhandled_input(event):
	if event is InputEventKey or event is InputEventMouse:
		if event.is_pressed():
			menu.menu_shown = true
		

func _get_average(samples: Array[float]) -> float:
	var mag_sum: float = 0.0
	for i in samples:
		mag_sum += i
	return mag_sum / float(samples.size())
	

func _on_v_slider_drag_ended(value_changed):
	Save.threshold = %ThesholdSlider.value

func _on_animator_stopped(anim_name):
	if is_talking:
		animator.play("bounce")
	
