class_name ScreenObjectMenu extends PanelContainer

signal request_gizmo(ScreenObject)

@export var objectpath:NodePath=""
var object: ScreenObject

signal request_file(ScreenObject)

func _delete_object():
	if object:
		object.queue_free()
	queue_free()

func _set_blinks(value):
	object.blinking = value
	
func _set_bounces(value):
	object.reactive = value
	
func _set_talks(value):
	object.talking = value

func _request_file():
	emit_signal("request_file", object)
	print("file")

func _request_gizmo():
	emit_signal("request_gizmo", object)
	print("giz")

func _ready():
	owner=get_parent().owner
	if objectpath!=NodePath(""):
		print(objectpath)
		object=get_node(objectpath)
	var menu=owner.get_node("Menu")
	connect("request_gizmo",Callable(menu,"_on_drag_requested"),CONNECT_PERSIST)
	connect("request_file",Callable(menu,"_on_file_button_button_down"),CONNECT_PERSIST)
	call_deferred("setpath" ,object)
		
func setpath(val):
	objectpath=get_path_to(val)
	pass
