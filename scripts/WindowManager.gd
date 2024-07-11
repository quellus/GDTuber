extends Node

# TODO: Save default_window_size
var default_window_size : Vector2i = Vector2i(1280,800)

func change_window_size(size: Vector2i):
	DisplayServer.window_set_size(size)

# NOTE: This function can be reused to toggle fullscreen mode
func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		if DisplayServer.window_get_size() == Vector2i(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height")):
			change_window_size(default_window_size)
	return DisplayServer.window_get_mode()
