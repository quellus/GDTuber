class_name LineEditReset extends LineEdit

var lastchange: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	focus_exited.connect(reset_text)
	text_submitted.connect(set_reset_text)
	pass # Replace with function body.

func reset_text():
	text = lastchange

func set_reset_text(value):
	lastchange = value
	text = value
	release_focus()
