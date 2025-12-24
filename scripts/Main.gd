class_name Menu extends Control

#Audio
const MAX_SAMPLES = 20

# Screen Object Management
@export var ObjectsRoot: Node
@export var MenusRoot: Node
@export var gizmo: Gizmo

# Screen Object Editing

# The project version is stored in Project Settings->Config->Version
var project_version = ProjectSettings.get_setting("application/config/version")

var localization = Localization.new()

var language_map: Dictionary = {}

var menu_shown = false:
	set(value):
		menu_shown = value
		_set_menu_shown(value)

var is_talking := false:
	set(value):
		if value != is_talking:
			for screen_object in get_tree().get_nodes_in_group("reactive"):
				if screen_object is ScreenObject:
					screen_object.is_talking = value
		is_talking = value


#Audio Vars
var bus_index
var analyzer: AudioEffectSpectrumAnalyzerInstance
var samples: Array[float] = []
var amplifier_effect = AudioEffectAmplify
var threshold = 0.5
var input_gain: float
var input_device: String


# Window Management
@onready var titleedit: LineEdit = %TitleEdit
@onready var profilename: String = "GDTuber Avatar"
@onready var mainmenu: Control = %MainMenu
@onready var settings_menu: Control = %SettingsMenu
@onready var background = %Background
@onready var bg_color = %BackgroundColor
@onready var bg_transparent_toggle = %BGTransparentToggle
@onready var bg_color_picker = %ColorPickerButton
@onready var background_transparent: bool = !background.visible
@onready var background_color: Color = background.color
@onready var menu = %Menu
@onready var window_size_container = %WindowSize
@onready var fixed_window_width_spinbox = %fixedWindowWidthSpinbox
@onready var fixed_window_width: int
@onready var fixed_window_height_spinbox = %fixedWindowHeightSpinbox
@onready var fixed_window_height: int
@onready var fixed_window_size_toggle = %FixedWindowSizeToggle
@onready var fixed_window_size: bool = false

@onready var fps_cap_toggle = %FPSCapToggle
@onready var max_fps_spinbox = %MaxFPSSpinbox
@onready var fps_cap: bool = false
@onready var fps_cap_value: int = 0
var FPS_LABEL_SETTING : String = ""

# Audio Management
@onready var input_gain_slider: Slider = %InputGainSlider
@onready var threshold_slider: Slider = %ThresholdSlider
@onready var device_dropdown := %DeviceDropdown

# File Management
@onready var file_dialog: FileDialog = %ImageOpenDialog
@onready var json_save_dialog: FileDialog = %JSONSaveDialog
@onready var json_load_dialog: FileDialog = %JSONLoadDialog

### Ready
func _ready():
	# Set Window Properties
	get_tree().get_root().set_transparent_background(true)

	# Set FPS translation label for later translations
	FPS_LABEL_SETTING = %CurrentFPSLabel.text

	# Set Audio Properties
	bus_index = AudioServer.get_bus_index("Record")
	amplifier_effect = AudioServer.get_bus_effect(bus_index, 1)
	var popup_menu = device_dropdown.get_popup()
	var devices = AudioServer.get_input_device_list()
	popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
	for device_name in devices:
		popup_menu.add_item(device_name)
	%VersionLabel.text = "Version: " + ProjectSettings.get_setting("application/config/version")

	# Initialize Localization
	localization.language_dropdown = %LanguageDropdown
	localization.setup()

	# Initialize Menu
	menu_shown = true
	SceneFileLoad.load_scene_from_file(PlatformConsts.AUTOSAVE_PATH, self)

	_load_system_data()


### Process
func _process(_delta):
	# Audio Processing
	var current_db = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)
	var magnitude = db_to_linear(current_db)

	if samples.size() >= MAX_SAMPLES:
		samples.pop_front()
	samples.append(magnitude)

	var magnitude_avg = _get_average()

	if magnitude_avg > threshold:
		if !is_talking:
			is_talking = true
	else:
		if is_talking:
			is_talking = false

	%VolumeVisual.value = magnitude_avg
	
	%CurrentFPSLabel.set_text("%s %.1f" % [ tr(FPS_LABEL_SETTING), Engine.get_frames_per_second()])


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_autosave()
		get_tree().quit()  # default behavior


### Handle Save event from button click
func _save_file(path: String):
	SceneFileSave.save_scene_to_file(self, path)


func _on_save_button():
	json_save_dialog.popup_centered()


func _autosave():
	SystemSettings.save_system_data(input_device, threshold, input_gain)
	SceneFileSave.save_scene_to_file(self)


func _order_object_in_scene():
	for node: ScreenObjectMenu in MenusRoot.get_children():
		ObjectsRoot.move_child(node.object, node.get_index())

func _request_image(requestor_menu: ScreenObjectMenu, imageproperty: String, pathproperty: String):
	file_dialog.file_selected.connect(func file_selector_return(path):
		requestor_menu.set_screen_object_image(path, imageproperty, pathproperty))
	file_dialog.popup_centered()

func _duplicate_object_in_scene(object_for_duplication: ScreenObject):
	var screen_object_menu_ui = ScreenObjectMenu.create_screen_object_menu_with_default_scene_object()
	var new_copied_object = screen_object_menu_ui.object
	add_scene_object_with_ui_to_scene(screen_object_menu_ui)

	for property in object_for_duplication.copy_properties:
		new_copied_object.set(property, object_for_duplication.get(property))

func add_scene_object_with_ui_to_scene(screen_object_menu_ui: ScreenObjectMenu):
	var new_onscreen_object = screen_object_menu_ui.object
	
	ObjectsRoot.add_child(new_onscreen_object)
	MenusRoot.add_child(screen_object_menu_ui)
	new_onscreen_object.user_position = MenusRoot.get_viewport_rect().size / 2

	screen_object_menu_ui.request_gizmo.connect(gizmo.request_screen_object_gizmo_focus)
	screen_object_menu_ui.grab_gizmo.connect(gizmo.handle_object_recenter)
	screen_object_menu_ui.tree_exiting.connect(gizmo.handle_clear)
	screen_object_menu_ui.request_image.connect(_request_image)
	screen_object_menu_ui.duplicate_object.connect(_duplicate_object_in_scene)
	screen_object_menu_ui.order_changed.connect(_order_object_in_scene)
	gizmo.gizmo_changed.connect(screen_object_menu_ui.update_gizmo_button)
	screen_object_menu_ui.update_menu()


func _add_new_object_to_scene():
	if MenusRoot and ObjectsRoot:
		add_scene_object_with_ui_to_scene(
			ScreenObjectMenu.create_screen_object_menu_with_default_scene_object())

func _load_system_data():
	var system_setting_array: Array = SystemSettings.load_system_data()

	if system_setting_array.is_empty() == false:
		input_device = system_setting_array[0]
		threshold = system_setting_array[1]
		input_gain = system_setting_array[2]
		var locale = system_setting_array[3]

		AudioServer.set_input_device(input_device)
		threshold_slider.value = threshold
		input_gain_slider.value = input_gain

		if locale != TranslationServer.get_locale():
			localization.set_locale(locale)


func _load_dialog():
	json_load_dialog.popup_centered()


func _load_data(path: String):
	SceneFileLoad.load_scene_from_file(path, self)
	gizmo.request_screen_object_gizmo_focus(null)


func _on_autosave_timer_timeout():
	_autosave()


### Window Management
func _set_menu_shown(value: bool):
	menu.visible = value
	# set_process_input(value)


func _on_button_button_down():
	menu_shown = false


func _on_quit_button_button_down():
	SystemSettings.save_system_data(input_device, threshold, input_gain)
	_save_file(PlatformConsts.AUTOSAVE_PATH)
	get_tree().quit()


func _on_fixed_window_button_toggled(value):
	var windowsize = DisplayServer.window_get_size()
	fixed_window_size = value
	WindowManager.toggle_fixed_window_size(windowsize, value)
	if value == true:
		fixed_window_width_spinbox.value = windowsize.x
		fixed_window_height_spinbox.value = windowsize.y
		window_size_container.show()
	else:
		window_size_container.hide()


func _on_ws_lock_width_value_changed(value):
	if fixed_window_size_toggle.button_pressed and fixed_window_width != value:
		fixed_window_width = value
		WindowManager.toggle_fixed_window_size(Vector2i(fixed_window_width, fixed_window_height), value)


func _on_ws_lock_height_value_changed(value):
	if fixed_window_size_toggle.button_pressed and fixed_window_height != value:
		fixed_window_height = value
		WindowManager.toggle_fixed_window_size(Vector2i(fixed_window_width, fixed_window_height), value)


func _on_fullscreen_toggle():
	WindowManager.toggle_fullscreen()


func _open_settings():
	settings_menu.visible = true
	mainmenu.visible = false


func _close_settings():
	mainmenu.visible = true
	settings_menu.visible = false

func _toggle_transparent(value):
	bg_color.visible = !value
	background.visible = !value
	background_transparent = value

func _change_background_color(color):
	background.color = color
	background_color = color

func _set_profile_name(pname: String):
	titleedit.text = pname
	profilename = pname
	get_tree().get_root().title = pname


### Audio Management
func _on_popup_menu_index_pressed(index: int):
	var popup_menu = device_dropdown.get_popup()
	input_device = popup_menu.get_item_text(index)
	AudioServer.set_input_device(input_device)


func _get_average() -> float:
	var mag_sum: float = 0.0
	var mag_avg: float = 0.0
	for i in samples:
		mag_sum += i
	mag_avg = mag_sum / float(samples.size())
	return mag_avg


func update_amplifier(_new_input_gain: float):
	if _new_input_gain <= -10.0 || _new_input_gain >= 24.1:
		return
	if amplifier_effect.volume_db != _new_input_gain:
		amplifier_effect.volume_db = _new_input_gain


func _on_v_slider_drag_ended(value_changed):
	threshold = value_changed


func _on_input_gain_change(_new_input_gain: float):
	input_gain = _new_input_gain
	update_amplifier(_new_input_gain)


### Input
func _unhandled_input(event):
	# Toggle Menu
	if event is InputEventKey or event is InputEventMouse:
		if event.is_pressed():
			menu_shown = true


func _on_fps_cap_toggled(toggled_on: bool) -> void:
	fps_cap = toggled_on
	if not toggled_on:
		%FPSDropdownContainer.hide()
		Engine.set_max_fps(0)
		return

	%FPSDropdownContainer.show()
	_on_max_fps_spinbox_value_changed(%MaxFPSSpinbox.get_value())


func _on_max_fps_spinbox_value_changed(value: float) -> void:
	fps_cap_value = int(value)
	if int(value) != Engine.get_max_fps():
		Engine.set_max_fps(int(value))


func _on_audio_reset_timer_timeout() -> void:
	print_debug("Resetting audio device")
	var orig_device = AudioServer.input_device
	var devices = AudioServer.get_input_device_list()
	var index = devices.find(orig_device)
	var rand_index = (index + randi_range(1, devices.size() - 1)) % devices.size()
	AudioServer.input_device = devices[rand_index]
	await get_tree().create_timer(0.2).timeout
	AudioServer.input_device = orig_device
