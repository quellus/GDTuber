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
