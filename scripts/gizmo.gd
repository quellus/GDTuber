class_name Gizmo extends Control

var dragging: bool
var target: ScreenObject

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventMouseMotion:
		if dragging:
			position += event.relative
			if target:
				target.global_position = global_position

func drag():
	if !dragging:
		dragging = true

func dragnt():
	dragging = false
