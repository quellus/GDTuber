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
const SCALE_RATIO = 1.1
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
const DEFAULT_IMAGE: String = "res://Assets/DefaultAvatar.png"
const DEFAULT_NEUTRAL_IMAGE: String = "res://Assets/DefaultAvatar-Neutral.png"
const DEFAULT_TALKING_IMAGE: String = "res://Assets/DefaultAvatar-Talking.png"
const DEFAULT_BLINKING_IMAGE: String = "res://Assets/DefaultAvatar-Blinking.png"
const DEFAULT_TALKING_AND_BLINKING_IMAGE : String = "res://Assets/DefaultAvatar-TalkingBlinking.png"
@export var ObjectsRoot: Node
@export var MenusRoot: Node
var default_avatar_texture: Texture2D = preload(DEFAULT_IMAGE)
var default_neutral_texture: Texture2D = preload(DEFAULT_NEUTRAL_IMAGE)
var default_talking_texture: Texture2D = preload(DEFAULT_TALKING_IMAGE)
var default_blinking_texture: Texture2D = preload(DEFAULT_BLINKING_IMAGE)
var default_talking_and_blinking_texture: Texture2D = preload(DEFAULT_TALKING_AND_BLINKING_IMAGE)
var somenuscene = preload("res://scenes/screen_object_menu.tscn")

# Screen Object Editing
const SNAP_ANGLE = PI/4
@export var gizmo: Gizmo
var drag_target: ScreenObject
var rotating = false
var rotation_center: Vector2 = Vector2()
var starting_rotation: float = 0

# File Management
@onready var file_dialog := %ImageOpenDialog
@onready var json_save_dialog : FileDialog = %JSONSaveDialog
@onready var json_load_dialog : FileDialog = %JSONLoadDialog
var openingfor: ScreenObject
var objectimagefield: String
var objectimagepathfield: String
var savedata: String
const AUTOSAVE_PATH: String = "user://autosave.gdtuber"
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
	var window: Window = get_tree().get_root()
	File_Loader.load_data(
		AUTOSAVE_PATH,
		MenusRoot,
		ObjectsRoot,
		project_version,
		window,
		titleedit,
		profilename,
		background_color,
		bgcolorPicker,
		background,
		bgcolor,
		background_transparent,
		bgTransparentToggle,
		fixedWindowSizeToggle,
		fixedWindowWidthSpinbox,
		fixedWindowHeightSpinbox,
		maxFpsSpinbox,
		fpsCapToggle,
		file_dialog,
		gizmo,
		drag_target
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

### File I/O
func _save_file(path: String):
	if path.get_extension() == "":
		path = path+".gdtuber"
	var save_game = FileAccess.open(path, FileAccess.WRITE)
	save_game.store_line(savedata)


func _on_save_button():
	_save_profile_data()
	json_save_dialog.popup_centered()


func _autosave():
	_save_profile_data()
	_save_system_data()
	_save_file(AUTOSAVE_PATH)


func _save_system_data():
	var config = ConfigFile.new()
	config.set_value("Audio", "input_device", input_device)
	config.set_value("Audio", "threshold", threshold)
	config.set_value("Audio", "input_gain", input_gain)
	config.set_value("Localization", "language", TranslationServer.get_locale())
	
	config.save(SYSTEM_CONFIG_PATH)


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


func _save_profile_data():
	json_save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	var savedict = {
		"version":project_version,
		"profile_name":profilename,
		"background_transparent":background_transparent,
		"background_color":background_color.to_html(),
		"fixedWindowWidth":fixedWindowWidth,
		"fixedWindowHeight":fixedWindowHeight,
		"fixedWindowSize":fixedWindowSize,
		"fpsCap": fpsCap,
		"fpsCapValue": fpsCapValue,
		"objects":[]
	}
	for obj in ObjectsRoot.get_children():
		if obj is ScreenObject:
			savedict["objects"].append({
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
			})
	savedata = JSON.stringify(savedict)


func _load_dialog():
	json_load_dialog.popup_centered()

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
	_save_profile_data()
	_save_file(AUTOSAVE_PATH)
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
func _input(event):

	if event is InputEventMouseMotion and drag_target and rotating:
		var rotvector = event.global_position-rotation_center
		var rotangle = atan2(rotvector.y, rotvector.x)
		var targetrot = rotangle+starting_rotation
		if Input.is_key_pressed(KEY_CTRL):
			drag_target.user_rotation = round(targetrot/SNAP_ANGLE)*SNAP_ANGLE
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
					drag_target.user_scale *= SCALE_RATIO
				MOUSE_BUTTON_WHEEL_DOWN:
					drag_target.user_scale *= 1 / SCALE_RATIO
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
