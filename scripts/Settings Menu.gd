class_name ScreenObjectSettingsPopup extends Popup

signal blink_speed_change(min_interval, max_interval)
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

func _ready():
	%BlinkMinIntervalIncreaseButton.pressed.connect(func(): update_blink_intervals(%BlinkMinIntervalIncreaseButton))
	%BlinkMinIntervalDecreaseButton.pressed.connect(func(): update_blink_intervals(%BlinkMinIntervalDecreaseButton))
	%BlinkMaxIntervalIncreaseButton.pressed.connect(func(): update_blink_intervals(%BlinkMaxIntervalIncreaseButton))
	%BlinkMaxIntervalDecreaseButton.pressed.connect(func(): update_blink_intervals(%BlinkMaxIntervalDecreaseButton))

	%BlinkDurationIncreaseButton.pressed.connect(func(): update_blink_duration(%BlinkDurationIncreaseButton))
	%BlinkDurationDecreaseButton.pressed.connect(func(): update_blink_duration(%BlinkDurationDecreaseButton))

func update_blink_duration(blinkdurationbutton: TextureButton):
	var min_duration = 1 
	var duration = int(blinkdurationsettingsdisplay.text)

	match blinkdurationbutton.name:
		"BlinkDurationIncreaseButton":
			duration+=1 
		"BlinkDurationDecreaseButton":
			duration-=1 

	if duration < min_duration: 
		duration=min_duration
	
	blinkdurationsettingsdisplay.text = str(duration)
	blink_duration_change.emit(duration)


func update_blink_intervals(blinkintervalbutton: TextureButton):
	var min_int = int(minintervalsettingsdisplay.text)
	var max_int = int(maxintervalsettingsdisplay.text)

	var min_first=true
	
	match blinkintervalbutton.name:
		"BlinkMinIntervalIncreaseButton":
			min_int+=1 
		"BlinkMinIntervalDecreaseButton":
			min_int-=1 
		"BlinkMaxIntervalIncreaseButton":
			min_first=false
			max_int+=1 
		"BlinkMaxIntervalDecreaseButton":
			min_first=false
			max_int-=1 

	var validated_min_max = min_max_validate(min_int, max_int, min_first)

	minintervalsettingsdisplay.text = str(validated_min_max[0])
	maxintervalsettingsdisplay.text = str(validated_min_max[1])

	blink_speed_change.emit(validated_min_max[0], validated_min_max[1])


func min_max_validate(min_blink_interval: int, max_blink_interval: int, min_first: bool):
	var max_min = 2
	var min_min = 1
	var min_blink: int = abs(min_blink_interval)
	var max_blink: int = abs(max_blink_interval)
	
	min_blink = min_min if  min_blink == 0 else min_blink
	max_blink = max_min if  max_blink == 1 else max_blink

	if min_first:
		if min_blink >= max_blink: 
			max_blink = min_blink+1
	else:
		if max_blink <= min_blink: 
			min_blink = max_blink-1

	return [min_blink, max_blink]







  
