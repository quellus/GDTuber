class_name OnScreenObjectMenu extends Node

static var screen_object_menu_scene = preload("res://scenes/screen_object_menu.tscn")

var file_dialog: Window 
var gizmo: Gizmo
var openingfor: ScreenObject
var objectimagefield: String
var objectimagepathfield: String
var newmenu: ScreenObjectMenu 
var drag_target: ScreenObject
var menu_root: Node
var objects_root: Node


func _request_image(requestor, imageproperty, pathproperty):
	openingfor = requestor
	objectimagefield = imageproperty
	objectimagepathfield = pathproperty
	file_dialog.popup_centered()

func _clear_gizmo():
	gizmo.target = null
	gizmo.visible = false

func _duplicate_object(obj: ScreenObject):
	var newobj = OnScreenObjectCreator.make_new_screen_object(menu_root, objects_root)
	OnScreenObjectMenu.new(menu_root,objects_root,newobj,file_dialog,gizmo,drag_target)

	for property in obj.copy_properties:
		newobj.set(property, obj.get(property))
	newobj.update_menu.emit()
	pass

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

func _grab_gizmo(object: ScreenObject):
	gizmo.global_position = object.global_position

func _order_objects():
	for node:ScreenObjectMenu in menu_root.get_children():
		objects_root.move_child(node.object, node.get_index())
		pass

func _connect_menu(smenu: ScreenObjectMenu):
	smenu.request_image.connect(_request_image)
	smenu.tree_exiting.connect(_clear_gizmo)
	smenu.duplicate_object.connect(_duplicate_object)
	smenu.request_gizmo.connect(_on_drag_requested)
	smenu.grab_gizmo.connect(_grab_gizmo)
	smenu.order_changed.connect(_order_objects)


func _init(menu_root_instance: Node,
		objects_root_instance: Node,
	 	connected_screen_object: ScreenObject, 
	 	file_dialog_window: Window,
	 	gizmo_instance: Gizmo,
	 	drag_target_instance: ScreenObject):
	
	file_dialog= file_dialog_window
	gizmo = gizmo_instance
	drag_target = drag_target_instance
	menu_root = menu_root_instance
	objects_root = objects_root_instance

	newmenu = screen_object_menu_scene.instantiate() as ScreenObjectMenu
	menu_root.add_child(newmenu)
	newmenu.object = connected_screen_object
	newmenu.update_menu()
	_connect_menu(newmenu) 

	