class_name PlatformConsts

const SYSTEM_CONFIG_PATH: String = "user://system_config.cfg"

const DEFAULT_IMAGE: String = "res://Assets/DefaultAvatar.png"

const AUTOSAVE_PATH: String = "user://autosave.gdtuber"

const SCALE_RATIO: float = 1.1
const SNAP_ANGLE: float = PI / 4

const DEFAULT_NEUTRAL_IMAGE: String = "res://Assets/DefaultAvatar-Neutral.png"
const DEFAULT_TALKING_IMAGE: String = "res://Assets/DefaultAvatar-Talking.png"
const DEFAULT_BLINKING_IMAGE: String = "res://Assets/DefaultAvatar-Blinking.png"
const DEFAULT_TALKING_AND_BLINKING_IMAGE: String = "res://Assets/DefaultAvatar-TalkingBlinking.png"

static var default_avatar_texture: Texture2D = preload(DEFAULT_IMAGE)
static var default_neutral_texture: Texture2D = preload(DEFAULT_NEUTRAL_IMAGE)
static var default_talking_texture: Texture2D = preload(DEFAULT_TALKING_IMAGE)
static var default_blinking_texture: Texture2D = preload(DEFAULT_BLINKING_IMAGE)
static var default_talking_and_blinking_texture: Texture2D = preload(
	DEFAULT_TALKING_AND_BLINKING_IMAGE
)
static var somenuscene = preload("res://scenes/screen_object_menu.tscn")
