class_name OnScreenObjectCreator extends Node

### Screen Object Management
static func make_new_screen_object() -> ScreenObject:
		var newobject: ScreenObject = ScreenObject.new()
		newobject.texture = PlatformConsts.default_avatar_texture
		newobject.neutral_texture = PlatformConsts.default_neutral_texture
		newobject.talking_texture = PlatformConsts.default_talking_texture
		newobject.blinking_texture = PlatformConsts.default_blinking_texture
		newobject.talking_and_blinking_texture = PlatformConsts.default_talking_and_blinking_texture
		return newobject  
