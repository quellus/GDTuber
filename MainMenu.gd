extends Control


func run():
	get_tree().change_scene_to_file("res://scenes/MicRecord.tscn")
	
	
func quit():
	get_tree().quit()
