class_name SystemSettings

const threshold_default: float = 0.5
const input_gain_default: float = 0.0


static func save_system_data(input_device: String, threshold: float, input_gain: float):
	var config = ConfigFile.new()
	config.set_value("Audio", "input_device", input_device)
	config.set_value("Audio", "threshold", threshold)
	config.set_value("Audio", "input_gain", input_gain)
	config.set_value("Localization", "language", TranslationServer.get_locale())

	config.save(PlatformConsts.SYSTEM_CONFIG_PATH)


static func load_system_data() -> Array:
	var config = ConfigFile.new()
	var settings_load_state: Error = config.load(PlatformConsts.SYSTEM_CONFIG_PATH)

	if settings_load_state == OK:
		var input_device = config.get_value("Audio", "input_device")
		var threshold = config.get_value("Audio", "threshold", threshold_default)
		var input_gain = config.get_value("Audio", "input_gain", input_gain_default)
		var locale = config.get_value("Localization", "language", TranslationServer.get_locale())

		return [input_device, threshold, input_gain, locale]

	return []
