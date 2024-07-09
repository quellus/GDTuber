class_name Menu extends Control


var somenuscene = preload("res://scenes/screen_object_menu.tscn")

const VERSION = 0.2
const DEFAULT_IMAGE: String = "res://DefaultAvatar.png"

@onready var device_dropdown := $PanelContainer/VBoxContainer/DeviceDropdown
@onready var file_dialog := %FileDialog

@export var ObjectsRoot: Node
@export var MenusRoot: Node
@export var gizmo: Gizmo
var drag_target: ScreenObject
var openingfor: ScreenObject 

var menu_shown = false:
	set(value): _set_menu_shown( value )

func _ready():
	menu_shown = true
	var popup_menu = device_dropdown.get_popup()
	popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
	var devices = AudioServer.get_input_device_list()
	for device_name in devices:
		popup_menu.add_item(device_name)

func _save_data():
	var save_game = FileAccess.open("user://gdtuber.json", FileAccess.WRITE)
	var savedict = {"version":VERSION, "objects":[]}
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
				"filter": obj.filter
			})
	save_game.store_line(JSON.stringify(savedict))


func _validate_object_json(dict, v) -> bool:
	var versions = {
		0.1:{
			"scale.x":float(),
			"scale.y":float(),
			"position.x":float(),
			"position.y":float(),
			"texturepath":String(),
			"blinking":bool(),
			"reactive":bool(),
			"talking":bool()
		},
		0.2:{
			"filter":bool()
		}
	}
	for version in versions:
		if version <= v:
			for field in versions[version]:
				if field not in dict:
					return false
				if !is_instance_of(dict[field], typeof(versions[version][field])):
					return false
	return true

func _load_data():
	var save_json = FileAccess.get_file_as_string("user://gdtuber.json")
	if save_json == "":
		return
	var save_dict = JSON.parse_string(save_json)
	var version = VERSION
	if save_dict:
		if "version" in save_dict:
			if save_dict["version"] is float:
				version = save_dict["version"]
		if version > VERSION:
			print("WARNING: save data is newer than current version, attempting to load data")
		if "objects" in save_dict:
			if save_dict["objects"] is Array:
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
						newobj.update_menu.emit()
					else:
						print("ERROR: object does not contain required fields")
			else:
				print("ERROR: dictionary contains no \"objects\" field")
	else:
		print("ERROR: JSON file is invalid")

func _set_menu_shown(value: bool):
	visible = value
	set_process_input(value)

func _create_new_object():
	if MenusRoot and ObjectsRoot:
		var newmenu: ScreenObjectMenu = somenuscene.instantiate()
		var newobject: ScreenObject = ScreenObject.new()
		newmenu.object = newobject
		newobject.texture = ImageTexture.create_from_image(Image.load_from_file(DEFAULT_IMAGE))
		newmenu.request_file.connect(_on_file_button_button_down)
		newmenu.tree_exiting.connect(clear_gizmo)
		MenusRoot.add_child(newmenu)
		ObjectsRoot.add_child(newobject)
		newmenu.request_gizmo.connect(_on_drag_requested)
		newmenu.grab_gizmo.connect(_grab_gizmo)
		newobject.user_position = newobject.global_position
		newmenu.update_menu()
		return newobject

func _on_button_button_down():
	menu_shown = false

func _on_quit_button_button_down():
	get_tree().quit()

func _on_popup_menu_index_pressed(index: int):
	var popup_menu = device_dropdown.get_popup()
	AudioServer.set_input_device(popup_menu.get_item_text(index))
	pass


func _on_file_button_button_down(requestor):
	openingfor = requestor
	file_dialog.popup_centered()


func _request_image(path):
	if openingfor:
		var image = Image.new()
		var err = image.load(path)
		if err != OK:
			printerr("cannot load image.")
			return
		Save.filepath = path
		openingfor.texture = ImageTexture.create_from_image(image)
		openingfor.texturepath = path

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
