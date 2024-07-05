class_name ScreenObjectMenu extends PanelContainer

signal request_gizmo(ScreenObject)

@export var objectpath:NodePath=""
var object: ScreenObject:
	set(val):
		object=val
		setpath(val)

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

func _request_gizmo():
	emit_signal("request_gizmo", object)

func _ready():
	owner=get_parent().owner
	if objectpath!=NodePath(""):
		print(objectpath)
		object=get_node(objectpath)
	request_gizmo.connect(Callable(owner,"_on_drag_requested"))
	request_file.connect(Callable(owner,"_on_file_button_button_down"))
	call_deferred("setpath" ,object)
	print("#($9$",get_signal_connection_list("request_gizmo"))
		
func setpath(val):
	objectpath=val.get_path()
	pass
