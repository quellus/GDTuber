class_name Gizmo extends Control

signal gizmo_focus_requested(ScreenObject)

var dragging: bool
var target: ScreenObject


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if dragging:
		if event is InputEventMouseMotion:
			position += event.relative
			if target:
				target.global_position = global_position
				target.user_position = target.global_position


func request_screen_object_gizmo_focus(object_requesting_gizmo: ScreenObject):
	gizmo_focus_requested.emit(object_requesting_gizmo)


func drag():
	if !dragging:
		dragging = true


func dragnt():
	dragging = false
