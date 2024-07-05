extends Control


func run():
	get_tree().change_scene_to_file("res://MicRecord.tscn")
	
	
func quit():
	get_tree().quit()
