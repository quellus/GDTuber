class_name ScreenObjectMenu extends PanelContainer

signal request_image(obj:ScreenObject, img:String, prop:String)

signal request_gizmo(ScreenObject)
signal grab_gizmo(ScreenObject)
signal duplicate_object(ScreenObject)
signal order_changed()

@export var popupanchor: Control
@export var name_field: LineEditReset
@onready var visibilitytoggle: BaseButton = %VisibilityToggle
@onready var settingsmenu: ScreenObjectSettingsPopup = $HBoxContainer/Control/Popup4
var object: ScreenObject:
	set(value):
		if value:
			value.update_menu.connect(update_menu)
		object = value


func _ready():
	settingsmenu.blinktoggle.toggled.connect(_set_blinks)
	settingsmenu.bouncetoggle.toggled.connect(_set_bounce)
	settingsmenu.mouthtoggle.toggled.connect(_set_mouth)
	settingsmenu.filtertoggle.toggled.connect(_set_filter)
	settingsmenu.hueslider.value_changed.connect(_set_hue)
	settingsmenu.satslider.value_changed.connect(_set_sat)
	settingsmenu.valslider.value_changed.connect(_set_val)
	settingsmenu.heightslider.value_changed.connect(_set_height)
	settingsmenu.speedslider.value_changed.connect(_set_speed)

	settingsmenu.togglemultiimage.connect(_toggle_multi_image)

	settingsmenu.requestimage.connect(_request_image)
	settingsmenu.requestneutral.connect(_request_neutral)
	settingsmenu.requestblinking.connect(_request_blinking)
	settingsmenu.requesttalking.connect(_request_talking)
	settingsmenu.requesttalkingandblinking.connect(_request_talking_and_blinking)

func _toggle_multi_image(value):
	object.usesingleimage = value
	settingsmenu.singleimageselect.visible = value
	settingsmenu.multiimageselect.visible = !value
	pass


func _set_name(value: String):
	object.user_name = value


func _request_image():
	emit_signal("request_image", object, "texture", "texturepath")
func _request_neutral():
	emit_signal("request_image", object, "neutral_texture", "neutralpath")
func _request_blinking():
	emit_signal("request_image", object, "blinking_texture", "blinkingpath")
func _request_talking():
	emit_signal("request_image", object, "talking_texture", "talkingpath")
func _request_talking_and_blinking():
	emit_signal("request_image", object, "talking_and_blinking_texture", "talkingandblinkingpath")


func _request_gizmo():
	emit_signal("request_gizmo", object)


func _open_menu():
	var popuprect = popupanchor.get_global_rect()
	popuprect.size = Vector2(256, 256)
	settingsmenu.popup_on_parent(popuprect)


func _set_blinks(value):
	object.blinking = value
func _set_mouth(value):
	object.talking = value
func _set_filter(value):
	object.filter = value

func _set_bounce(value):
	object.reactive = value
func _set_speed(value):
	object.user_speed = value
func _set_height(value):
	object.user_height = value

func _set_hue(value):
	object.user_hue = value
func _set_sat(value):
	object.user_sat = value
func _set_val(value):
	object.user_val = value


func update_menu():
	if visibilitytoggle:
		visibilitytoggle.button_pressed = object.user_hidden
	if name_field:
		name_field.set_reset_text(object.user_name)
	if settingsmenu:
		settingsmenu.blinktoggle.button_pressed = object.blinking
		settingsmenu.bouncetoggle.button_pressed = object.reactive
		settingsmenu.mouthtoggle.button_pressed = object.talking
		settingsmenu.filtertoggle.button_pressed = object.filter
		settingsmenu.hueslider.value = object.user_hue
		settingsmenu.satslider.value = object.user_sat
		settingsmenu.valslider.value = object.user_val
		settingsmenu.heightslider.value = object.user_height
		settingsmenu.speedslider.value = object.user_speed
		settingsmenu.imagepreview.texture = object.texture
		settingsmenu.neutralpreview.texture = object.neutral_texture
		settingsmenu.blinkingpreview.texture = object.blinking_texture
		settingsmenu.talkingpreview.texture = object.talking_texture
		settingsmenu.talkingandblinkingpreview.texture = object.talking_and_blinking_texture
		settingsmenu.singleimagetoggle.button_pressed = object.usesingleimage

func _shift_up():
	get_parent().move_child(self, get_index()-1)
	order_changed.emit()
	pass


func _shift_down():
	get_parent().move_child(self, get_index()+1)
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


func _duplicate():
	duplicate_object.emit(object)
	pass


func _delete_object():
	if object:
		object.queue_free()
	queue_free()
