extends Node

# TODO: Save default_window_size
var default_window_size: Vector2i = Vector2i(1280, 800)


func change_window_size(size: Vector2i):
	DisplayServer.window_set_size(size)


# NOTE: This function can be reused to toggle fullscreen mode
func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var width = ProjectSettings.get_setting("display/window/size/viewport_width")
		var height = ProjectSettings.get_setting("display/window/size/viewport_height")
		if DisplayServer.window_get_size() == Vector2i(width, height):
			change_window_size(default_window_size)
	return DisplayServer.window_get_mode()


# NOTE: this function can be used to disable resizing the window and sets it to specific size
func toggle_fixed_window_size(size: Vector2i, lock: bool):
	if lock:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
		change_window_size(size)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
		change_window_size(size)
	return
