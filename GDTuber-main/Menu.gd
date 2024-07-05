class_name Menu extends Control

@onready var device_dropdown := $PanelContainer/VBoxContainer/DeviceDropdown
@onready var file_dialog := %FileDialog
@onready var sprite = %AvatarSprite

var menu_shown = false:
	set(value): _set_menu_shown( value )

func _ready():
	menu_shown = false
	if device_dropdown != null:
		var popup_menu = device_dropdown.get_popup()
		popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
		var devices = AudioServer.get_input_device_list()
		for device_name in devices:
			popup_menu.add_item(device_name)

func _set_menu_shown(value: bool):
	visible = value
	set_process_input(value)


func _on_button_button_down():
	menu_shown = false

func _on_quit_button_button_down():
	get_tree().quit()
	
func _on_popup_menu_index_pressed(index: int):
	var popup_menu = device_dropdown.get_popup()
	AudioServer.set_input_device(popup_menu.get_item_text(index))
	pass


func _on_file_button_button_down():
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path):
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		print("AAAAAA")
		return
	Save.filepath = path
	var width = floor(image.get_width()/2)
	var height = floor(image.get_height()/2)
	for i in range(4):
		var atlas = AtlasTexture.new()
		var atlas_rect
		match i:
			0:
				atlas_rect = Rect2(0, 0, width, height)
			1:
				atlas_rect = Rect2(width, 0, width, height)
			2:
				atlas_rect = Rect2(0, height, width, height)
			3:
				atlas_rect = Rect2(width, height, width, height)
				
		atlas.atlas = ImageTexture.new().create_from_image(image)
		atlas.region = atlas_rect
		%AvatarSprite.sprite_frames.set_frame("default", i, atlas)
	%AvatarSprite._reposition()
