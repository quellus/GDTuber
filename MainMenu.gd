extends Control

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
	WindowManager.change_window_size(WindowManager.default_window_size)
	run_app()
	
func run_fullscreen():
	print("run fullscreen")
	WindowManager.toggle_fullscreen()
	run_app()
	
func quit_app():
	get_tree().quit()
