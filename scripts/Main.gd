class_name Menu extends Control

# The project version is stored in Project Settings->Config->Version
var project_version = ProjectSettings.get_setting("application/config/version")

var localization = Localization.new()

var language_map: Dictionary = {}

# Window Management
@onready var titleedit: LineEdit = %TitleEdit
@onready var profilename: String = "GDTuber Avatar"
@onready var mainmenu: Control = %MainMenu
@onready var settingsmenu: Control = %SettingsMenu
@onready var background = %Background
@onready var bgcolor = %BackgroundColor
@onready var bgTransparentToggle = %BGTransparentToggle
@onready var bgcolorPicker = %ColorPickerButton
@onready var background_transparent: bool = !background.visible
@onready var background_color: Color = background.color
@onready var menu = %Menu
@onready var windowsizecontainer = %WindowSize
@onready var fixedWindowWidthSpinbox = %fixedWindowWidthSpinbox
@onready var fixedWindowWidth: int
@onready var fixedWindowHeightSpinbox = %fixedWindowHeightSpinbox
@onready var fixedWindowHeight: int
@onready var fixedWindowSizeToggle = %FixedWindowSizeToggle
@onready var fixedWindowSize: bool = false
var menu_shown = false:
	set(value):
		menu_shown = value
		_set_menu_shown(value)
@onready var fpsCapToggle = %FPSCapToggle
@onready var maxFpsSpinbox = %MaxFPSSpinbox
@onready var fpsCap: bool = false
@onready var fpsCapValue: int = 0

# Audio Management
const MAX_SAMPLES = 20
@onready var input_gain_slider: Slider = %InputGainSlider
@onready var threshold_slider: Slider = %ThresholdSlider
@onready var device_dropdown := %DeviceDropdown
var bus_index
var analyzer: AudioEffectSpectrumAnalyzerInstance
var samples: Array[float] = []
var amplifier_effect = AudioEffectAmplify
var threshold = 0.5
var input_gain: float
var input_device: String

# Screen Object Management
@export var ObjectsRoot: Node
@export var MenusRoot: Node


# Screen Object Editing
@export var gizmo: Gizmo

#var drag_target: ScreenObject

# File Management
@onready var file_dialog :FileDialog= %ImageOpenDialog
@onready var json_save_dialog : FileDialog = %JSONSaveDialog
@onready var json_load_dialog : FileDialog = %JSONLoadDialog

const SYSTEM_CONFIG_PATH: String = "user://system_config.cfg"

### Ready
func _ready():
	# Set Window Properties
	get_tree().get_root().set_transparent_background(true)

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
	File_Loader.load_data(
		PlatformConsts.AUTOSAVE_PATH,
		self
	)
	
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
	
	%CurrentFPSLabel.set_text("Current FPS %.1f" % Engine.get_frames_per_second())

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_autosave()
		get_tree().quit() # default behavior

### Handle Save event from button click 
func _save_file(path: String):
	# try catch here? 
	var scene_state_json: String = File_Saver.serialize_scene_state_to_json(self)
	File_Saver.save_to_file(scene_state_json, path)



func _on_save_button():
	json_save_dialog.popup_centered()


func _autosave():

	# should probably be in a try catch?
	_save_system_data() # for audio stuff 
	_save_file(PlatformConsts.AUTOSAVE_PATH)

func _save_system_data():
	var config = ConfigFile.new()
	config.set_value("Audio", "input_device", input_device)
	config.set_value("Audio", "threshold", threshold)
	config.set_value("Audio", "input_gain", input_gain)
	config.set_value("Localization", "language", TranslationServer.get_locale())
	
	config.save(SYSTEM_CONFIG_PATH)


func _add_new_object_to_scene():
	var new_onscreen_object = OnScreenObjectCreator.make_new_screen_object(MenusRoot, ObjectsRoot)
	OnScreenObjectMenuController.new(
						MenusRoot,
						ObjectsRoot,
						new_onscreen_object,
						file_dialog,
						gizmo,
					)


func _load_system_data():
	var config = ConfigFile.new()
	var err: Error = config.load(SYSTEM_CONFIG_PATH)
	if err == OK:
		input_device = config.get_value("Audio", "input_device", input_device)
		AudioServer.set_input_device(input_device)
		threshold = config.get_value("Audio", "threshold", threshold)
		threshold_slider.value = threshold
		input_gain = config.get_value("Audio", "input_gain", input_gain)
		input_gain_slider.value = input_gain
		
		var locale = config.get_value("Localization", "language", TranslationServer.get_locale())
		if locale != TranslationServer.get_locale():
			localization.set_locale(locale)

func _load_dialog():
	json_load_dialog.popup_centered()

func _load_data(path: String):
	File_Loader.load_data(
		path,
		self
	)

func _on_autosave_timer_timeout():
	_autosave()

### Window Management
func _set_menu_shown(value: bool):
	menu.visible = value
	# set_process_input(value)

func _on_button_button_down():
	menu_shown = false

func _on_quit_button_button_down():
	_save_system_data()
	_save_file(PlatformConsts.AUTOSAVE_PATH)
	get_tree().quit()


func _on_fixed_window_button_toggled(value):
	var windowsize = DisplayServer.window_get_size()
	fixedWindowSize = value
	WindowManager.toggle_fixed_window_size(windowsize,value)
	if value == true:
		fixedWindowWidthSpinbox.value = windowsize.x
		fixedWindowHeightSpinbox.value = windowsize.y
		windowsizecontainer.show()
	else:
		windowsizecontainer.hide()

func _on_ws_lock_width_value_changed(value):
	if fixedWindowSizeToggle.button_pressed and fixedWindowWidth != value:
		fixedWindowWidth = value
		WindowManager.toggle_fixed_window_size(Vector2i(fixedWindowWidth,fixedWindowHeight),value)

func _on_ws_lock_height_value_changed(value):
	if fixedWindowSizeToggle.button_pressed and fixedWindowHeight != value:
		fixedWindowHeight = value
		WindowManager.toggle_fixed_window_size(Vector2i(fixedWindowWidth,fixedWindowHeight),value)

func _on_fullscreen_toggle():
	WindowManager.toggle_fullscreen()

func _open_settings():
	settingsmenu.visible = true
	mainmenu.visible = false

func _close_settings():
	mainmenu.visible = true
	settingsmenu.visible = false


### Audio Management
func _on_popup_menu_index_pressed(index: int):
	var popup_menu = device_dropdown.get_popup()
	input_device = popup_menu.get_item_text(index)
	AudioServer.set_input_device(input_device)


var is_talking := false:
	set(value):
		if value != is_talking:
			for screen_object in get_tree().get_nodes_in_group("reactive"):
				if screen_object is ScreenObject:
					screen_object.is_talking = value
		is_talking = value

func _get_average() -> float:
	var mag_sum: float = 0.0
	var mag_avg: float = 0.0
	for i in samples:
		mag_sum += i
	mag_avg = mag_sum / float(samples.size())
	return mag_avg

func update_amplifier(_new_input_gain : float):
	if _new_input_gain <= -10.0 || _new_input_gain >= 24.1:
		return
	if amplifier_effect.volume_db != _new_input_gain:
		amplifier_effect.volume_db = _new_input_gain

func _on_v_slider_drag_ended(value_changed):
	threshold = value_changed

func _on_input_gain_change(_new_input_gain : float):
	input_gain = _new_input_gain
	update_amplifier(_new_input_gain)


### Input
func _unhandled_input(event):
	# Toggle Menu
	if event is InputEventKey or event is InputEventMouse:
		if event.is_pressed():
			menu_shown = true


func _on_fps_cap_toggled(toggled_on: bool) -> void:
	fpsCap = toggled_on
	if not toggled_on:
		%FPSDropdownContainer.hide()
		Engine.set_max_fps(0)
		return
	
	%FPSDropdownContainer.show()
	_on_max_fps_spinbox_value_changed(%MaxFPSSpinbox.get_value())

func _on_max_fps_spinbox_value_changed(value: float) -> void:
	fpsCapValue = int(value)
	if int(value)!= Engine.get_max_fps():
		Engine.set_max_fps(int(value))
