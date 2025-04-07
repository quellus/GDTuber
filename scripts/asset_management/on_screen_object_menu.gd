
# should probably be renamed to onscreen object user interface controller or something
class_name OnScreenObjectMenu extends Node

static var screen_object_menu_scene = preload("res://scenes/screen_object_menu.tscn")

var rotating = false
var rotation_center: Vector2 = Vector2()
var starting_rotation: float = 0
var file_dialog: FileDialog 
var gizmo: Gizmo
var openingfor: ScreenObject
var objectimagefield: String
var objectimagepathfield: String
var newmenu: ScreenObjectMenu 
var drag_target: ScreenObject
var menu_root: Node
var objects_root: Node

func _update_image(path):
	file_dialog.file_selected.disconnect(_update_image)
	File_Loader.open_image(path, self)

func _request_image(requestor, imageproperty, pathproperty):
	openingfor = requestor
	objectimagefield = imageproperty
	objectimagepathfield = pathproperty
	file_dialog.file_selected.connect(_update_image)
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

func _input(event):
	if event is InputEventMouseMotion and drag_target and rotating:
		var rotvector = event.global_position-rotation_center
		var rotangle = atan2(rotvector.y, rotvector.x)
		var targetrot = rotangle+starting_rotation
		if Input.is_key_pressed(KEY_CTRL):
			drag_target.user_rotation = round(targetrot/AssetConsts.SNAP_ANGLE)*AssetConsts.SNAP_ANGLE
		else:
			drag_target.user_rotation = targetrot

	if event is InputEventMouseButton and drag_target:
			match event.button_index:
				MOUSE_BUTTON_RIGHT:
					if event.is_pressed():
						if !rotating:
							rotation_center = drag_target.global_position
							var rotvector = event.global_position-rotation_center
							var rotangle = atan2(rotvector.y, rotvector.x)
							starting_rotation = drag_target.user_rotation - rotangle
							rotating = true
					else:
						rotating = false

func _unhandled_input(event):
	# Scroll to zoom
	if event is InputEventMouseButton and drag_target:
		if is_instance_valid(drag_target):
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					drag_target.user_scale *= AssetConsts.SCALE_RATIO
				MOUSE_BUTTON_WHEEL_DOWN:
					drag_target.user_scale *= 1 / AssetConsts.SCALE_RATIO


func _init(menu_root_instance: Node,
		objects_root_instance: Node,
	 	connected_screen_object: ScreenObject, 
	 	file_dialog_window: FileDialog,
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
	objects_root.add_child(self)

	