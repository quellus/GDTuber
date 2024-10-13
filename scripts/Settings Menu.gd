class_name ScreenObjectSettingsPopup extends Popup

@onready var hueslider: Slider = %HueSlider
@onready var satslider: Slider = %SatSlider
@onready var valslider: Slider = %ValSlider
@onready var alpslider: Slider = %AlpSlider

@onready var mouthtoggle: Button = %MouthBox
@onready var blinktoggle: Button = %BlinkBox
@onready var filtertoggle: Button = %FilterBox
@onready var timertoggle: Button = %TimerBox
@onready var timersettings: PanelContainer = %TimerSettings
@onready var timerspinbox: SpinBox = %TimerSpinBox

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
