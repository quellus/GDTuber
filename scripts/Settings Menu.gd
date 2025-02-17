class_name ScreenObjectSettingsPopup extends Popup

signal min_blink_speed_change(min_interval)
signal max_blink_speed_change(max_interval)
signal blink_duration_change(blink_duration)

@onready var hueslider: Slider = %HueSlider
@onready var satslider: Slider = %SatSlider
@onready var valslider: Slider = %ValSlider

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

@onready var minintervalsettingsdisplay = %MinBlinkIntervalSettingsInput
@onready var maxintervalsettingsdisplay = %MaxBlinkIntervalSettingsInput

@onready var blinkdurationsettingsdisplay = %BlinkDurationSettingsInput



func update_blink_duration(value: float):
	blink_duration_change.emit(value)


func update_max_blink_interval(value: float):
	if value < %MinBlinkIntervalSettingsInput.value:
		%MinBlinkIntervalSettingsInput.value = value
	max_blink_speed_change.emit(value)


func update_min_blink_interval(value: float):
	if value > %MaxBlinkIntervalSettingsInput.value:
		%MaxBlinkIntervalSettingsInput.value = value
	min_blink_speed_change.emit(value)  

func sync_ui_hight_val_changed(value: float): 
	%HeightSpinBox.value = value
	%HeightSlider.value = value

func sync_ui_speed_val_changed(value: float): 
	%SpeedSpinBox.value = value
	%SpeedSlider.value = value

func sync_ui_hue_val_changed(value: float): 
	%HueSpinBox.value = value
	%HueSlider.value = value

func sync_ui_sat_val_changed(value: float):
	%SatSliderSpin.value = value
	%SatSlider.value = value

func sync_ui_val_val_changed(value: float): 
	%ValSpinBox.value = value
	%ValSlider.value = value
