extends AnimatedSprite2D

var blinking = false
@onready var timer = $BlinkTimer
var rng = RandomNumberGenerator.new()

func _ready():
	get_tree().root.size_changed.connect(_reposition)
	_reposition()
	
func _reposition():
	print("resized")
	offset = sprite_frames.get_frame_texture(animation, frame).get_size() / -2
	position = Vector2.ZERO

func _on_blink_timer_timeout():
	if blinking == false:
		frame += 2
		blinking = true
		timer.start(0.2)
	else:
		frame -= 2
		blinking = false
		timer.start(rng.randf_range(2, 4))
