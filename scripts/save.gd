extends Node
class_name LayoutSaver

static var filepath: String="user://save.tscn"
static func save(node):
	var scene=PackedScene.new()
	scene.pack(node)
	ResourceSaver.save(scene,filepath)

func load():
	if ResourceLoader.exists(filepath):
		get_tree().change_scene_to_packed(load(filepath))
	else:
		get_tree().change_scene_to_file("res://scenes/MicRecord.tscn")

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
