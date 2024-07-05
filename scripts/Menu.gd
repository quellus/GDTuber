class_name Menu extends Control


var somenuscene = preload("res://scenes/screen_object_menu.tscn")

@onready var device_dropdown := $PanelContainer/VBoxContainer/DeviceDropdown
@onready var file_dialog := %FileDialog

@export var ObjectsRoot: Node
@export var MenusRoot: Node
@export var gizmo: Gizmo
var drag_target: ScreenObject
var openingfor: ScreenObject 

var menu_shown = false:
	set(value): _set_menu_shown( value )

func _ready():
	menu_shown = true
	var popup_menu = device_dropdown.get_popup()
	popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
	var devices = AudioServer.get_input_device_list()
	for device_name in devices:
		popup_menu.add_item(device_name)

func _set_menu_shown(value: bool):
	visible = value
	set_process_input(value)

func _create_new_object():
	if MenusRoot and ObjectsRoot:
		var newmenu: ScreenObjectMenu = somenuscene.instantiate()
		var newobject: ScreenObject = ScreenObject.new()
		newmenu.object = newobject
		newobject.texture = ImageTexture.create_from_image(Image.load_from_file("res://DefaultAvatar.png"))
		newmenu.request_file.connect(_on_file_button_button_down)
		MenusRoot.add_child(newmenu)
		ObjectsRoot.add_child(newobject)
		newmenu.request_gizmo.connect(_on_drag_requested)

func _on_button_button_down():
	menu_shown = false

func _on_quit_button_button_down():
	get_tree().quit()

func _on_popup_menu_index_pressed(index: int):
	var popup_menu = device_dropdown.get_popup()
	AudioServer.set_input_device(popup_menu.get_item_text(index))
	pass


func _on_file_button_button_down(requestor):
	openingfor = requestor
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path):
	if openingfor:
		var image = Image.new()
		var err = image.load(path)
		if err != OK:
			printerr("cannot load image.")
			return
		Save.filepath = path
		openingfor.texture = ImageTexture.create_from_image(image)


func _on_drag_requested(object: ScreenObject):
	if drag_target == object:
		drag_target = null
		gizmo.visible = false
		gizmo.target = null
	else:
		gizmo.global_position = object.global_position
		gizmo.visible = true
		gizmo.target = object
		drag_target = object
