class_name OnScreenObjectMenuController extends Node

signal object_duplication_request(ScreenObject)
signal object_reorder_request

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


func _handle_gizmo_focus_request(object_requesting_gizmo: ScreenObject):
	if drag_target == object_requesting_gizmo or object_requesting_gizmo == null:
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


func _connect_signals():
	screen_object_menu_ui.request_image.connect(_request_image)
	screen_object_menu_ui.tree_exiting.connect(_clear_gizmo)
	screen_object_menu_ui.duplicate_object.connect(
		func(object_for_duplication: ScreenObject):
			object_duplication_request.emit(object_for_duplication)
	)
	screen_object_menu_ui.request_gizmo.connect(_on_request_gizmo_focus)
	screen_object_menu_ui.grab_gizmo.connect(_grab_gizmo)
	screen_object_menu_ui.order_changed.connect(func(): object_reorder_request.emit())

	gizmo.gizmo_focus_requested.connect(_handle_gizmo_focus_request)


func _input(event):
	if event is InputEventMouseMotion and drag_target and rotating:
		var rotvector = event.global_position - rotation_center
		var rotangle = atan2(rotvector.y, rotvector.x)
		var targetrot = rotangle + starting_rotation
		if Input.is_key_pressed(KEY_CTRL):
			drag_target.user_rotation = (
				round(targetrot / PlatformConsts.SNAP_ANGLE) * PlatformConsts.SNAP_ANGLE
			)
		else:
			drag_target.user_rotation = targetrot

	if event is InputEventMouseButton and drag_target:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					if !rotating:
						rotation_center = drag_target.global_position
						var rotvector = event.global_position - rotation_center
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
					drag_target.user_scale *= PlatformConsts.SCALE_RATIO
				MOUSE_BUTTON_WHEEL_DOWN:
					drag_target.user_scale *= 1 / PlatformConsts.SCALE_RATIO


func _init(connected_screen_object: ScreenObject, file_dialog_window: FileDialog, gizmo_instance: Gizmo):
	file_dialog = file_dialog_window
	gizmo = gizmo_instance
	screen_object_menu_ui = screen_object_menu_scene.instantiate() as ScreenObjectMenu
	screen_object_menu_ui.object = connected_screen_object
	# screen_object_menu_ui.update_menu()
	_connect_signals()
