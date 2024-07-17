class_name ScreenObjectMenu extends PanelContainer

signal request_gizmo(ScreenObject)
signal grab_gizmo(ScreenObject)
signal duplicate_object(ScreenObject)
signal order_changed()
# signal set_filter(ScreenObject, bool)

@export var talkbox: CheckBox
@export var bouncebox: CheckBox
@export var blinkbox: CheckBox

@export var filterbox: CheckBox
@export var visibilitytoggle: TextureButton
@export var popupanchor: Control

@export var name_field: LineEditReset

@onready var colorpopup: ColorPopup = $HBoxContainer/Control/Popup
@onready var settingspopup: ObjectSettings = $HBoxContainer/Control/Popup2
@onready var tweenpopup: TweenSettings = $HBoxContainer/Control/Popup3

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

func _set_speed(speed):
	object.user_speed = speed
	pass

func _set_height(height):
	object.user_height = height

func _ready():
	settingspopup.blinkbox.toggled.connect(_set_blinks)
	settingspopup.bouncebox.toggled.connect(_set_bounces)
	settingspopup.mouthbox.toggled.connect(_set_talks)
	settingspopup.filterbox.toggled.connect(_set_filter)
	
	tweenpopup.heightslider.value_changed.connect(_set_height)
	tweenpopup.speedslider.value_changed.connect(_set_speed)
	pass


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
	if colorpopup:
		colorpopup.hueslider.value = object.user_hue
		colorpopup.satslider.value = object.user_sat
		colorpopup.valslider.value = object.user_val
	if settingspopup:
		settingspopup.blinkbox.button_pressed = object.blinking
		settingspopup.bouncebox.button_pressed = object.reactive
		settingspopup.filterbox.button_pressed = object.filter
		settingspopup.mouthbox.button_pressed = object.talking
	if tweenpopup:
		tweenpopup.heightslider.value = object.user_height
		tweenpopup.speedslider.value = object.user_speed
	pass

func _duplicate():
	duplicate_object.emit(object)
	pass

func _shift_up():
	get_parent().move_child(self, get_index()-1)
	# object.get_parent().move_child(object, get_index()-1)
	order_changed.emit()
	pass

func _shift_down():
	get_parent().move_child(self, get_index()+1)
	# object.get_parent().move_child(object, get_index()+1)
	order_changed.emit()
	pass

func _recenter():
	var viewportsize = object.get_viewport_rect().size
	object.user_position = viewportsize/2
	object.get_viewport_transform()
	grab_gizmo.emit(object)
	pass

func _togglevisibility(value):
	object.user_hidden = value

func _open_menu():
	var popuprect = popupanchor.get_global_rect()
	popuprect.size = Vector2(200, 150)
	colorpopup.popup_on_parent(popuprect)

func _open_settings():
	var popuprect = popupanchor.get_global_rect()
	popuprect.size = Vector2(200, 115)
	settingspopup.popup_on_parent(popuprect)

func _open_tween():
	var popuprect = popupanchor.get_global_rect()
	popuprect.size = Vector2(110, 175)
	tweenpopup.popup_on_parent(popuprect)

func _update_hue(value):
	object.user_hue = value
func _update_sat(value):
	object.user_sat = value
func _update_val(value):
	object.user_val = value
	
