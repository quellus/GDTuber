extends Control

@onready var shortcutsRoot=$Popup4/Control/PanelContainer/TabContainer/shortcuts/ScrollContainer/shortcutImagesRoot
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _input(event):
	if event is InputEventKey:
		for child in shortcutsRoot.get_children():
			if child is PanelContainer:
				child.custom_input(event)
