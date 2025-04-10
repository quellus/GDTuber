class_name OnScreenObjectMenuController extends Node

static var screen_object_menu_scene = preload("res://scenes/screen_object_menu.tscn")

var drag_target: ScreenObject
var rotating = false
var rotation_center: Vector2 = Vector2()
var starting_rotation: float = 0
var openingfor: ScreenObject
var objectimagefield: String
var objectimagepathfield: String
var screen_object_menu_ui: ScreenObjectMenu 

var file_dialog: FileDialog 
var gizmo: Gizmo

var menu_root: Node
var objects_root: Node

func open_image(path):
	if openingfor:
		var image = Image.new()
		var err = image.load(path)
		if err != OK:
			push_error("cannot load image.")
			return

		openingfor.set(objectimagefield, ImageTexture.create_from_image(image))
		openingfor.set(objectimagepathfield, path)

func _update_image(path):
	file_dialog.file_selected.disconnect(_update_image)
	open_image(path)

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
	OnScreenObjectMenuController.new(menu_root,objects_root,newobj,file_dialog,gizmo)

	for property in obj.copy_properties:
		newobj.set(property, obj.get(property))
	newobj.update_menu.emit()
	pass

func _handle_gizmo_focus_request(object_requesting_gizmo: ScreenObject):
	if drag_target == object_requesting_gizmo:
		drag_target = null
		gizmo.visible = false
		gizmo.target = null
	else:
		gizmo.global_position = object_requesting_gizmo.global_position
		gizmo.visible = true
		gizmo.target = object_requesting_gizmo
		drag_target = object_requesting_gizmo

func _on_request_gizmo_focus(object: ScreenObject):
	gizmo.request_screen_object_gizmo_focus(object)

func _grab_gizmo(object: ScreenObject):
	gizmo.global_position = object.global_position

func _order_objects():
	for node:ScreenObjectMenu in menu_root.get_children():
		objects_root.move_child(node.object, node.get_index())
		pass

func _connect_signals():
	screen_object_menu_ui.request_image.connect(_request_image)
	screen_object_menu_ui.tree_exiting.connect(_clear_gizmo)
	screen_object_menu_ui.duplicate_object.connect(_duplicate_object)
	screen_object_menu_ui.request_gizmo.connect(_on_request_gizmo_focus)
	screen_object_menu_ui.grab_gizmo.connect(_grab_gizmo)
	screen_object_menu_ui.order_changed.connect(_order_objects)

	gizmo.gizmo_focus_requested.connect(_handle_gizmo_focus_request)

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
	 	gizmo_instance: Gizmo):
	
	file_dialog= file_dialog_window
	gizmo = gizmo_instance
	menu_root = menu_root_instance
	objects_root = objects_root_instance
	screen_object_menu_ui = screen_object_menu_scene.instantiate() as ScreenObjectMenu
	menu_root.add_child(screen_object_menu_ui)	
	screen_object_menu_ui.object = connected_screen_object
	screen_object_menu_ui.update_menu()

	_connect_signals() 
	objects_root.add_child(self)

	