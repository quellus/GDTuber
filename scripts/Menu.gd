class_name Menu extends Control

const VERSION = 0.6

# Window Management
@onready var titleedit: LineEdit = %TitleEdit
@onready var profilename: String = "GDTuber Avatar"
@onready var mainmenu: Control = %MainMenu
@onready var settingsmenu: Control = %SettingsMenu
@onready var background = %Background
@onready var bgcolor = %BackgroundColor
@onready var menu = %Menu
var menu_shown = false:
	set(value): _set_menu_shown( value )

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

# Screen Object Management
const DEFAULT_IMAGE: String = "res://assets/DefaultAvatar.png"
@export var ObjectsRoot: Node
@export var MenusRoot: Node
var default_avatar_texture: Texture2D = preload(DEFAULT_IMAGE)
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
var savedata: String

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
	
	# Initialize Menu
	menu_shown = true



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



### File I/O
func _save_file(path: String):
	if path.get_extension() == "":
		path = path+".json"
	var save_game = FileAccess.open(path, FileAccess.WRITE)
	save_game.store_line(savedata)

func _save_data():
	json_save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	var savedict = {
		"version":VERSION, 
		"threshold":threshold,
		"input_gain":input_gain,
		"profile_name":profilename,
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
			})
	savedata = JSON.stringify(savedict)
	json_save_dialog.popup_centered()

func _validate_save_json(dict, v) -> bool:
	pass
	var versions = {
		0.1:{
			"objects":TYPE_ARRAY,
			"version":TYPE_FLOAT
		},
		0.3:{
			"threshold":TYPE_FLOAT,
			"input_gain":TYPE_FLOAT
		},
		0.4:{
			"profile_name":TYPE_STRING,
		}
	}
	for version in versions:
		if version <= v:
			for field in versions[version]:
				if field not in dict:
					return false
				if !is_instance_of(dict[field], versions[version][field]):
					return false
	return true

func _validate_object_json(dict, v) -> bool:
	var versions = {
		0.1:{
			"scale.x":TYPE_FLOAT,
			"scale.y":TYPE_FLOAT,
			"position.x":TYPE_FLOAT,
			"position.y":TYPE_FLOAT,
			"texturepath":TYPE_STRING,
			"blinking":TYPE_BOOL,
			"reactive":TYPE_BOOL,
			"talking":TYPE_BOOL
		},
		0.2:{
			"filter":TYPE_BOOL
		},
		0.4:{
			"rotation":TYPE_FLOAT
		},
		0.5:{
			"hidden":TYPE_BOOL
		},
		0.6:{
			"name":TYPE_STRING,
		}
	}
	for version in versions:
		if version <= v:
			for field in versions[version]:
				if field not in dict:
					return false
				if !is_instance_of(dict[field], versions[version][field]):
					return false
	return true

func _load_dialog():
	json_load_dialog.popup_centered()

func _load_data(path):
	var save_json = FileAccess.get_file_as_string(path)
	if save_json == "":
		return
	var save_dict = JSON.parse_string(save_json)
	var version = 0.1
	if save_dict:
		if "version" in save_dict:
			if save_dict["version"] is float:
				version = save_dict["version"]
		if _validate_save_json(save_dict, version):
			version = save_dict["version"]
			# Version Check
			if version > VERSION:
				push_warning("WARNING: save data is newer than current version, attempting to load data")
			
			# Generate Objects from Objects Array
			for obj in ObjectsRoot.get_children():
				obj.queue_free()
			for men in MenusRoot.get_children():
				men.queue_free()
			for obj in save_dict["objects"]:
				if _validate_object_json(obj, version):
					# 0.1
					var newobj = _create_new_object()
					newobj.user_scale = Vector2(obj["scale.x"], obj["scale.y"])
					newobj.user_position = Vector2(obj["position.x"], obj["position.y"])
					newobj.blinking = obj["blinking"]
					newobj.reactive = obj["reactive"]
					newobj.talking = obj["talking"]
					if obj["texturepath"] != "":
						openingfor = newobj
						_request_image(obj["texturepath"])
					# 0.2
					if version >= 0.2:
						newobj.filter = obj["filter"]
					# 0.4
					if version >= 0.4:
						newobj.user_rotation = obj["rotation"]
					# 0.5
					if version >= 0.5:
						newobj.user_hidden = obj["hidden"]
					# 0.6
					if version >= 0.6:
						newobj.user_name = obj["name"]
					newobj.update_menu.emit()
				else:
					push_error("ERROR: object does not contain required fields")
			# Load Program Settings
			# 0.3
			if version >= 0.3:
				threshold = save_dict["threshold"]
				threshold_slider.value = threshold
				input_gain = save_dict["input_gain"]
				input_gain_slider.value = input_gain
			#0.4
			if version >= 0.4:
				titleedit.text = save_dict["profile_name"]
				_set_profile_name(save_dict["profile_name"])
		else:
			push_error("ERROR: Required Fields for Save File Version not Found")
	else:
		push_error("ERROR: JSON file is invalid")
	
func _on_file_button_button_down(requestor):
	openingfor = requestor
	file_dialog.popup_centered()

func _request_image(path):
	if openingfor:
		var image = Image.new()
		var err = image.load(path)
		if err != OK:
			push_error("cannot load image.")
			return
		openingfor.texture = ImageTexture.create_from_image(image)
		openingfor.texturepath = path



### Window Management
func _set_menu_shown(value: bool):
	menu.visible = value
	set_process_input(value)

func _on_button_button_down():
	menu_shown = false

func _on_quit_button_button_down():
	get_tree().quit()

func _on_fullscreen_toggle():
	WindowManager.toggle_fullscreen()
	
func _open_settings():
	settingsmenu.visible = true
	mainmenu.visible = false

func _close_settings():
	mainmenu.visible = true
	settingsmenu.visible = false

func _toggle_transparent(value):
	bgcolor.visible = !value
	background.visible = !value
	
func _change_background_color(color):
	background.color = color

func _set_profile_name(pname: String):
	profilename = pname
	get_tree().get_root().title = pname



### Screen Object Management
func _create_new_object():
	if MenusRoot and ObjectsRoot:
		var newmenu: ScreenObjectMenu = somenuscene.instantiate() as ScreenObjectMenu
		var newobject: ScreenObject = ScreenObject.new()
		newobject.texture = default_avatar_texture
		MenusRoot.add_child(newmenu)
		ObjectsRoot.add_child(newobject)
		newmenu.object = newobject
		_connect_menu(newmenu)
		newobject.user_position = get_viewport_rect().size/2
		newmenu.update_menu()
		return newobject

func _connect_menu(smenu: ScreenObjectMenu):
	smenu.request_file.connect(_on_file_button_button_down)
	smenu.tree_exiting.connect(clear_gizmo)
	smenu.duplicate_object.connect(_duplicate_object)
	smenu.request_gizmo.connect(_on_drag_requested)
	smenu.grab_gizmo.connect(_grab_gizmo)
	smenu.order_changed.connect(_order_objects)

func clear_gizmo():
	gizmo.target = null
	gizmo.visible = false

func _grab_gizmo(object: ScreenObject):
	gizmo.global_position = object.global_position

func _on_drag_requested(object: ScreenObject):
	if drag_target == object:
		drag_target = null
		gizmo.visible = false
		gizmo.target = null
	else:
		gizmo.global_position = object.global_position
		gizmo.visible = true
		gizmo.target = object
		drag_target = object

func _duplicate_object(obj: ScreenObject):
	var newobj = _create_new_object()
	newobj.user_position = obj.user_position
	newobj.user_hidden = obj.user_hidden
	newobj.user_rotation = obj.user_rotation
	newobj.user_scale = obj.user_scale
	newobj.texturepath = obj.texturepath
	newobj.texture = obj.texture
	newobj.filter = obj.filter
	newobj.reactive = obj.reactive
	newobj.talking = obj.talking
	newobj.blinking = obj.blinking
	newobj.user_name = obj.user_name
	newobj.update_menu.emit()
	pass

func _order_objects():
	for node:ScreenObjectMenu in MenusRoot.get_children():
		ObjectsRoot.move_child(node.object, node.get_index())
		pass



### Audio Management
func _on_popup_menu_index_pressed(index: int):
	var popup_menu = device_dropdown.get_popup()
	AudioServer.set_input_device(popup_menu.get_item_text(index))
	pass

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
