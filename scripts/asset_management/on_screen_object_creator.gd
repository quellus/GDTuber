class_name OnScreenObjectCreator extends Node

# var openingfor: ScreenObject
# var objectimagefield: String
# var objectimagepathfield: String

# @onready var file_dialog := %ImageOpenDialog
# @export var gizmo: Gizmo
# var drag_target: ScreenObject

#func _request_image(requestor, imageproperty, pathproperty):
#	openingfor = requestor
#	objectimagefield = imageproperty
#	objectimagepathfield = pathproperty
#	file_dialog.popup_centered()
#
#func clear_gizmo():
#	gizmo.target = null
#	gizmo.visible = false
#
#func _duplicate_object(obj: ScreenObject):
#	var newobj = self.make_new_screen_object()
#
#	for property in obj.copy_properties:
#		newobj.set(property, obj.get(property))
#	newobj.update_menu.emit()
#	pass
#
#func _on_drag_requested(object: ScreenObject):
#	if drag_target == object:
#		drag_target = null
#		gizmo.visible = false
#		gizmo.target = null
#	else:
#		gizmo.global_position = object.global_position
#		gizmo.visible = true
#		gizmo.target = objectaaaa
#		drag_target = object
#
#func _grab_gizmo(object: ScreenObject):
#	gizmo.global_position = object.global_position

#func _order_objects():
#	for node:ScreenObjectMenu in MenusRoot.get_children():
#		ObjectsRoot.move_child(node.object, node.get_index())
#		pass


### Screen Object Management
static func make_new_screen_object(menu_root: Node = null, objects_root: Node = null) -> ScreenObject:
	if menu_root and objects_root:
		
		var newobject: ScreenObject = ScreenObject.new()

		newobject.texture = AssetConsts.default_avatar_texture
		newobject.neutral_texture = AssetConsts.default_neutral_texture
		newobject.talking_texture = AssetConsts.default_talking_texture
		newobject.blinking_texture = AssetConsts.default_blinking_texture
		newobject.talking_and_blinking_texture = AssetConsts.default_talking_and_blinking_texture
		objects_root.add_child(newobject)

		newobject.user_position = menu_root.get_viewport_rect().size/2  
		return newobject  
	else:
		return null
