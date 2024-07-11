extends LineEditReset


func _ready():
	super()
	text_submitted.connect(on_text_submitted)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed:
		var local = make_input_local(event) as InputEventMouseButton
		if !Rect2(Vector2(0, 0), size).has_point(local.position):
			set_reset_text(text)
			release_focus()


func on_text_submitted(new_text: String):
	release_focus()
