class_name SceneFileSave


static func _write_json_file_system(state_as_json_string: String, path: String):
	if path.get_extension() == "":
		path = path + ".gdtuber"
	var save_game = FileAccess.open(path, FileAccess.WRITE)
	save_game.store_line(state_as_json_string)


static func serialize_scene_state_to_json(main_menu: Menu) -> String:
	var file_dialog_window = main_menu.file_dialog
	var json_save_dialog = main_menu.json_save_dialog
	var main_scene_objects_root = main_menu.ObjectsRoot

	# this feels weird
	json_save_dialog.file_mode = file_dialog_window.FILE_MODE_SAVE_FILE

	var savedict = {
		"version": main_menu.project_version,
		"profile_name": main_menu.profilename,
		"background_transparent": main_menu.background_transparent,
		"background_color": main_menu.background_color.to_html(),
		"fixedWindowWidth": main_menu.fixedWindowWidth,
		"fixedWindowHeight": main_menu.fixedWindowHeight,
		"fixedWindowSize": main_menu.fixedWindowSize,
		"fpsCap": main_menu.fpsCap,
		"fpsCapValue": main_menu.fpsCapValue,
		"objects": []
	}

	for obj in main_scene_objects_root.get_children():
		if obj is ScreenObject:
			savedict["objects"].append(
				{
					"scale.x": obj.user_scale.x,
					"scale.y": obj.user_scale.y,
					"position.x": obj.user_position.x,
					"position.y": obj.user_position.y,
					"texturepath": obj.texturepath,
					"blinking": obj.blinking,
					"reactive": obj.reactive,
					"talking": obj.talking,
					"filter": obj.filter,
					"rotation": obj.user_rotation,
					"hidden": obj.user_hidden,
					"name": obj.user_name,
					"hue": obj.user_hue,
					"sat": obj.user_sat,
					"val": obj.user_val,
					"height": obj.user_height,
					"min_blink_delay": obj.min_blink_delay,
					"max_blink_delay": obj.max_blink_delay,
					"blink_duration": obj.blink_duration,
					"speed": obj.user_speed,
					"neutralpath": obj.neutralpath,
					"blinkingpath": obj.blinkingpath,
					"talkingpath": obj.talkingpath,
					"talkingandblinkingpath": obj.talkingandblinkingpath,
					"usesingleimage": obj.usesingleimage,
					"auto_toggle_enabled": obj.auto_toggle_enabled,
					"auto_toggle_time": obj.auto_toggle_time
				}
			)
	return JSON.stringify(savedict)


static func save_scene_to_file(main_menu: Menu, path: String = PlatformConsts.AUTOSAVE_PATH):
	var scene_state_json: String = serialize_scene_state_to_json(main_menu)
	_write_json_file_system(scene_state_json, path)
