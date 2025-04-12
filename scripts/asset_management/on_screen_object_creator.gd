class_name OnScreenObjectCreator extends Node

### Screen Object Management
static func make_new_screen_object(menu_root: Node = null, objects_root: Node = null) -> ScreenObject:
	if menu_root and objects_root:
		
		var newobject: ScreenObject = ScreenObject.new()

		newobject.texture = PlatformConsts.default_avatar_texture
		newobject.neutral_texture = PlatformConsts.default_neutral_texture
		newobject.talking_texture = PlatformConsts.default_talking_texture
		newobject.blinking_texture = PlatformConsts.default_blinking_texture
		newobject.talking_and_blinking_texture = PlatformConsts.default_talking_and_blinking_texture
		objects_root.add_child(newobject)

		newobject.user_position = menu_root.get_viewport_rect().size/2  
		return newobject  
	else:
		return null
