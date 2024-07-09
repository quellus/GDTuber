class_name ScreenObjectMenu extends PanelContainer

signal request_gizmo(ScreenObject)
signal grab_gizmo(ScreenObject)

@export var blinkbox: CheckBox
@export var bouncebox: CheckBox
@export var talkbox: CheckBox

var object: ScreenObject:
	set(value):
		if value:
			value.update_menu.connect(_update_menu)
		object = value

var user_scale: Vector2:
	set(value):
		user_scale = value
		if object:
			object.user_scale = value
var user_position: Vector2:
	set(value):
		user_position = value
		if object:
			object.user_position = value

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

func _update_menu():
	if blinkbox:
		if object.blinking:
			blinkbox.button_pressed = true
	if bouncebox:
		if object.reactive:
			bouncebox.button_pressed = true
	if talkbox:
		if object.talking:
			talkbox.button_pressed = true
	pass
	
func _recenter():
	var viewportsize = object.get_viewport_rect().size
	object.user_position = viewportsize/2
	object.get_viewport_transform()
	grab_gizmo.emit(object)
	pass
