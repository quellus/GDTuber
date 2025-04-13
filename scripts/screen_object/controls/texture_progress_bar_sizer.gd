extends TextureProgressBar

func _ready():
	var new_scale: float = $"..".size.x / size.x
	scale.x = new_scale
	scale.y = new_scale
	position = Vector2.ZERO
