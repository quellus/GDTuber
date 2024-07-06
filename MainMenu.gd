extends Control


func run():
	$LayoutSaver.load()
	
	
func quit():
	get_tree().quit()
