class_name ScreenObjectMenu extends PanelContainer

signal request_gizmo(ScreenObject)

var object: ScreenObject

signal request_file(ScreenObject)

func _delete_object():
	if object:
		object.queue_free()
	queue_free()

func _set_blinks(value):
	object.blinking = value
	
func _set_bounces(value):
	object.reactive = value
	
func _set_talks(value):
	object.talking = value

func _request_file():
	emit_signal("request_file", object)

func _request_gizmo():
	emit_signal("request_gizmo", object)
