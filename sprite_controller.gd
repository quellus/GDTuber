extends AnimatedSprite2D

var blinking = false
@onready var timer = $BlinkTimer
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_blink_timer_timeout():
	if blinking == false:
		frame += 2
		blinking = true
		timer.start(0.2)
	else:
		frame -= 2
		blinking = false
		timer.start(rng.randf_range(2, 4))
