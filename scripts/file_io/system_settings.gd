class_name SystemSettings



static func save_system_data():
	var config = ConfigFile.new()
	config.set_value("Audio", "input_device", AudioManager.input_device)
	config.set_value("Audio", "threshold", AudioManager.threshold)
	config.set_value("Audio", "input_gain", AudioManager.input_gain)
	config.set_value("Localization", "language", TranslationServer.get_locale())

	config.save(PlatformConsts.SYSTEM_CONFIG_PATH)


static func load_system_data() -> Array:
	var config = ConfigFile.new()
	var settings_load_state: Error = config.load(PlatformConsts.SYSTEM_CONFIG_PATH)

	if settings_load_state == OK:
		var input_device = config.get_value("Audio", "input_device")
		var threshold = config.get_value("Audio", "threshold", AudioManager.THRESHOLD_DEFAULT)
		var input_gain = config.get_value("Audio", "input_gain", AudioManager.INPUT_GAIN_DEFAULT)
		var locale = config.get_value("Localization", "language", TranslationServer.get_locale())

		return [input_device, threshold, input_gain, locale]

	return []
