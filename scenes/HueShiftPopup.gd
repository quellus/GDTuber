class_name ColorPopup extends Popup

@export var hueslider: HSlider
@export var satslider: HSlider
@export var valslider: HSlider

signal huechanged(float)
signal satchanged(float)
signal valchanged(float)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_hue(value: float):
	huechanged.emit(value)

func update_sat(value: float):
	satchanged.emit(value)

func update_val(value: float):
	valchanged.emit(value)
