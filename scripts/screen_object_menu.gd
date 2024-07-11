class_name ScreenObjectMenu extends PanelContainer

signal request_gizmo(ScreenObject)
signal grab_gizmo(ScreenObject)
signal duplicate_object(ScreenObject)
# signal set_filter(ScreenObject, bool)

@export var talkbox: CheckBox
@export var bouncebox: CheckBox
@export var blinkbox: CheckBox
@export var filterbox: CheckBox
@export var visibilitytoggle: TextureButton

@export var name_field: LineEditReset

var object: ScreenObject:
	set(value):
		if value:
			value.update_menu.connect(update_menu)
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

var user_name: String:
	set(value):
		user_name = value
		if object:
			object.user_name = value

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

func _set_filter(value):
	if object:
		object.filter = value
	# set_filter.emit(object, value)

func _set_name(value: String):
	object.user_name = value

func update_menu():
	if visibilitytoggle:
		visibilitytoggle.button_pressed = object.user_hidden
	if blinkbox:
		blinkbox.button_pressed = object.blinking
	if bouncebox:
		bouncebox.button_pressed = object.reactive
	if talkbox:
		talkbox.button_pressed = object.talking
	if filterbox:
		filterbox.button_pressed = object.filter
	if name_field:
		name_field.set_reset_text(object.user_name)
	pass

func _duplicate():
	duplicate_object.emit(object)
	pass

func _recenter():
	var viewportsize = object.get_viewport_rect().size
	object.user_position = viewportsize/2
	object.get_viewport_transform()
	grab_gizmo.emit(object)
	pass

func _togglevisibility(value):
	object.user_hidden = value
