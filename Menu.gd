class_name Menu extends Control

@onready var device_dropdown := $VBoxContainer/DeviceDropdown

var menu_shown = false:
	set(value): _set_menu_shown( value )

func _ready():
	menu_shown = false
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
	print(popup_menu.get_item_text(index))

	AudioServer.set_input_device(popup_menu.get_item_text(index))
	pass
