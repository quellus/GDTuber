class_name ScreenObjectSettingsPopup extends Popup

@onready var hueslider: Slider = %HueSlider
@onready var satslider: Slider = %SatSlider
@onready var valslider: Slider = %ValSlider
@onready var alpslider: Slider = %AlpSlider

@onready var mouthtoggle: Button = %MouthBox
@onready var blinktoggle: Button = %BlinkBox
@onready var filtertoggle: Button = %FilterBox

@onready var bouncetoggle: Button = %BounceBox
@onready var speedslider: Slider = %SpeedSlider
@onready var heightslider: Slider = %HeightSlider

@onready var requestimage: Signal = %ImageButton.pressed
@onready var requestneutral: Signal = %NeutralImageButton.pressed
@onready var requestblinking: Signal = %BlinkingImageButton.pressed
@onready var requesttalking: Signal = %TalkingImageButton.pressed
@onready var requesttalkingandblinking: Signal = %TalkingAndBlinkingImageButton.pressed
@onready var togglemultiimage: Signal = %SingleMultiToggle.toggled

@onready var imagepreview: TextureRect = %ImagePreview
@onready var neutralpreview: TextureRect = %NeutralImagePreview
@onready var blinkingpreview: TextureRect = %BlinkingImagePreview
@onready var talkingpreview: TextureRect = %TalkingImagePreview
@onready var talkingandblinkingpreview: TextureRect = %TalkingAndBlinkingImagePreview

@onready var singleimageselect = %SelectSingleImage
@onready var multiimageselect = %SelectSeparateImages

@onready var neutralimageselect = %"Select Neutral Image"
@onready var blinkingimageselect = %"Blinking Image"
@onready var talkingimageselect = %"Talking Image"
@onready var talkingandblinkingimageselect = %"Talking + Blinking Image"
@onready var singleimagetoggle = %SingleMultiToggle

@onready var shortcutImageScene=preload("res://scenes/shortcut_image.tscn")
@onready var shortcutRoot=$Control/PanelContainer/TabContainer/shortcuts/ScrollContainer/shortcutImagesRoot

@onready var menu=$"../../.."
@onready var menuRoot=menu.get_parent()
@onready var shortcutSaveDirPath="user://shortcuts"
@onready var shortcutSaveImagesDirPath="user://shortcuts/images"
@onready var shortcutSaveImagesPath
@onready var shortcutSavePath



func makePaths():
	var menues=menuRoot.get_children()
	for i in range(len(menues)):
		if menues[i]==menu:
			shortcutSavePath=shortcutSaveDirPath+"/"+str(i)+"_menue.gdtuber"
			shortcutSaveImagesPath=shortcutSaveImagesDirPath+"/"+str(i)
			pass
		pass
	
	
	pass
func _on_add_shortcut_image_pressed():
	var newShortcutImage=shortcutImageScene.instantiate()
	shortcutRoot.add_child(newShortcutImage)
	save_data()
	
	pass # Replace with function body.
func _ready():
	makePaths()
	load_data()

func save_data(ignore:PanelContainer=null)->void:
	make_dir(shortcutSaveDirPath)
	make_dir(shortcutSaveImagesDirPath)
	var data=[]
	var children=shortcutRoot.get_children()
	for i in range(len(children)):
		if not children[i] is CenterContainer and children[i]!=ignore:
			var imagePath=shortcutSaveImagesPath+"_"+str(i)+".png"
			save_images(children[i].image.texture,imagePath)
			var childData={
				"imagePath":imagePath,
				"shortcut":children[i].shortcut,
			}
			data.append(childData)

	var jsonStringData=JSON.stringify(data)
		
	var file=FileAccess.open(shortcutSavePath,FileAccess.WRITE)
	file.store_string(jsonStringData)
	file.close()
	
	pass
func load_data()->void:
	var file=FileAccess.open(shortcutSavePath,FileAccess.READ)
	if file:
		var jsonStringData=file.get_as_text()
		file.close()
		var data=JSON.parse_string(jsonStringData)
		
		for shortcutData in data:
			var newShortcutImage=shortcutImageScene.instantiate()
			newShortcutImage.shortcut=int(shortcutData["shortcut"])
			#newShortcutImage.imageTexture
			newShortcutImage.imageTexture=load_images(shortcutData["imagePath"])
			print(newShortcutImage.name+"from menu")
			#print(newShortcutImage.image.name)
			shortcutRoot.add_child(newShortcutImage)
	else:
		print("no file")
	pass

func make_dir(path:String)->void:
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

func save_images(texture:Texture,path:String)->void:
	var image:Image=texture.get_image()
	image.save_png(path)


func load_images(path:String):
	var newImage=Image.new()
	var error=newImage.load(path)
	if error==OK:
		var newTexture=ImageTexture.new()
		newTexture.set_image(newImage)
		return newTexture
	else :print("not ok")
func delete_unused_images():
	pass


func _on_texture_button_pressed():
	
	for child in menuRoot.get_children():
		var child_popup= child.get_node("HBoxContainer/Control/Popup4")
		child_popup.makePaths()
		child_popup.save_data()
	pass # Replace with function body.


func _on_texture_button_2_pressed():
	for child in menuRoot.get_children():
		var child_popup= child.get_node("HBoxContainer/Control/Popup4")
		child_popup.makePaths()
		child_popup.save_data()
	pass # Replace with function body.
