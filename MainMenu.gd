extends Control

# TODO: Save default_window_size
var default_window_size : Vector2 = Vector2(1280,800)

@onready var run_window_button = $CenterContainer/VBoxContainer2/VBoxContainer/RunWindowButton
@onready var run_fullscreen_button = $CenterContainer/VBoxContainer2/VBoxContainer/RunFullscreenButton
@onready var quit_button = $CenterContainer/VBoxContainer2/VBoxContainer/QuitButton


func _ready():
	run_window_button.connect("pressed",run_windowed)
	run_fullscreen_button.connect("pressed",run_fullscreen)
	quit_button.connect("pressed",quit_app)

func run_app():
	get_tree().change_scene_to_file("res://scenes/MicRecord.tscn")

func run_windowed():
	print("run windowed")
	change_window_size(default_window_size)
	run_app()
	
func run_fullscreen():
	print("run fullscreen")
	toggle_fullscreen()
	run_app()
	
func quit_app():
	get_tree().quit()
	
func change_window_size(size: Vector2):
	DisplayServer.window_set_size(size)

# NOTE: This function can be reused to toggle fullscreen mode
func toggle_fullscreen():
	printt("window mode:", DisplayServer.window_get_mode())
	DisplayServer.window_set_mode(DisplayServer.window_get_mode() if DisplayServer.WINDOW_MODE_WINDOWED else DisplayServer.WINDOW_MODE_FULLSCREEN)
