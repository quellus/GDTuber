class_name OnScreenObjectCreator extends Node

var screen_object_menu_scene = preload("res://scenes/screen_object_menu.tscn")

var openingfor: ScreenObject
var objectimagefield: String
var objectimagepathfield: String

@onready var file_dialog := %ImageOpenDialog
@export var gizmo: Gizmo
var drag_target: ScreenObject

func _request_image(requestor, imageproperty, pathproperty):
	openingfor = requestor
	objectimagefield = imageproperty
	objectimagepathfield = pathproperty
	file_dialog.popup_centered()

func clear_gizmo():
	gizmo.target = null
	gizmo.visible = false

func _duplicate_object(obj: ScreenObject):
	var newobj = self.make_new_screen_object()

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

#func _order_objects():
#	for node:ScreenObjectMenu in MenusRoot.get_children():
#		ObjectsRoot.move_child(node.object, node.get_index())
#		pass


func _connect_menu(smenu: ScreenObjectMenu):
	smenu.request_image.connect(_request_image)
	smenu.tree_exiting.connect(clear_gizmo)
	smenu.duplicate_object.connect(_duplicate_object)
	smenu.request_gizmo.connect(_on_drag_requested)
	smenu.grab_gizmo.connect(_grab_gizmo)
	#smenu.order_changed.connect(_order_objects)


### Screen Object Management
func make_new_screen_object(menu_root: Node = null, objects_root: Node = null) -> ScreenObject:
	if menu_root and objects_root:
		var newmenu: ScreenObjectMenu = screen_object_menu_scene.instantiate() as ScreenObjectMenu
		var newobject: ScreenObject = ScreenObject.new()

		newobject.texture = AssetConsts.default_avatar_texture
		newobject.neutral_texture = AssetConsts.default_neutral_texture
		newobject.talking_texture = AssetConsts.default_talking_texture
		newobject.blinking_texture = AssetConsts.default_blinking_texture
		newobject.talking_and_blinking_texture = AssetConsts.default_talking_and_blinking_texture

		menu_root.add_child(newmenu)
		objects_root.add_child(newobject)
		newmenu.object = newobject
		_connect_menu(newmenu) 
		newobject.user_position = menu_root.get_viewport_rect().size/2  # menu_root may not be right. 
		newmenu.update_menu()
		return newobject # maybe should return a tuple here? 
	else:
		return null