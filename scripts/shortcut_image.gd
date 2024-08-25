extends PanelContainer

@onready var fileDialog:FileDialog=$FileDialog
@onready var image:TextureRect=$VBoxContainer/HBoxContainer/PanelContainer/image
var imagePath=null

@onready var shortcutButton=$VBoxContainer/HBoxContainer/changeShortcut
@onready var shortcutText=$VBoxContainer/HBoxContainer2/RichTextLabel

@onready var screenObjectMenu=$"../../../../../../../../../.."
@onready var popup=$"../../../../../../.."
var screenObject
var objectTexture
var imageTexture:Texture



@export var shortcut=89

var requesting=false
var readingkey=false
# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	call_deferred("define_object")
	shortcutText.bbcode_text ='shortcut key: [color=lime]'+OS.get_keycode_string(shortcut)+"[/color]"
	if imageTexture:
		image.texture=imageTexture
	print(name+" from self")
	
	pass # Replace with function body.


func define_object():
	screenObject=screenObjectMenu.object
	objectTexture=screenObject.texture 


func _on_change_shortcut_pressed():
	readingkey=true
	shortcutText.bbcode_text="[color=yellow]press a button[/color]"
	pass # Replace with function body.

func _input(event):
	if readingkey and event is InputEventKey and event.pressed:
		shortcut=event.keycode
		shortcutText.bbcode_text ='shortcut key: [color=lime]'+event.as_text()+"[/color]"
		popup.save_data()
		readingkey=false

func custom_input(event):
	if event is InputEventKey and  event.keycode==shortcut:
		if event.pressed:
			screenObject.texture=image.texture
			for child in screenObject.visualsroot.get_children():
				child.queue_free()
			screenObject.create_normal_sprite()
			screenObject.sprite.texture_filter = TEXTURE_FILTER_LINEAR if screenObject.filter else TEXTURE_FILTER_NEAREST
		else:
			screenObject.texture=objectTexture
			for child in screenObject.visualsroot.get_children():
				child.queue_free()
			screenObject._ready()
			


			print("pressed ",shortcut)
			

			

func change_image(_texture:Texture)->void:
	imageTexture=_texture


func _on_file_dialog_file_selected(path):
	if requesting:
		var newImage=Image.new()
		newImage.load(path)
		imagePath=path
		
		var texture=ImageTexture.new()
		texture.set_image(newImage)
		image.texture=texture
		requesting=false
		popup.save_data()
	pass # Replace with function body.


func _on_change_image_pressed():
	requesting=true
	fileDialog.popup()
	pass # Replace with function body.


func _on_button_pressed():
	popup.save_data(self)
	queue_free()
	pass # Replace with function body.
