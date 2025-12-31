class_name Localization

const DEFAULT_LANGUAGE_LABEL = "SETTINGS_LANGUAGE_DEFAULT_LABEL"

var language_dropdown: OptionButton = null  # this has to be set externally

var language_map: Dictionary = {}
var available_locales = TranslationServer.get_loaded_locales()


func _init() -> void:
	for locale in available_locales:
		language_map[TranslationServer.get_locale_name(locale)] = locale


func setup() -> void:
	set_language_from_os()
	_populate_dropdown()
	language_dropdown.item_selected.connect(_on_locale_changed)
	language_dropdown.selected = 0


func set_language_from_os():
	var os_locale = OS.get_locale()
	var os_lang = OS.get_locale_language()
	if os_lang in available_locales:
		TranslationServer.set_locale(os_lang)
	elif os_locale in available_locales:
		TranslationServer.set_locale(os_locale)
	else:
		TranslationServer.set_locale("en")


func set_locale(locale: String):
	TranslationServer.set_locale(locale)
	var language = TranslationServer.get_locale_name(locale)
	for i in range(language_dropdown.item_count):
		if language == language_dropdown.get_item_text(i):
			#print("selected ", i)
			language_dropdown.selected = i
			return


func _on_locale_changed(index: int) -> void:
	var language = language_dropdown.get_item_text(index)
	if index == 0:
		set_language_from_os()
	else:
		TranslationServer.set_locale(language_map[language])
		
	language_dropdown.set_item_text(0, tr(DEFAULT_LANGUAGE_LABEL))


func _populate_dropdown():
	language_dropdown.clear()
	language_dropdown.add_item(tr(DEFAULT_LANGUAGE_LABEL))
	for language in available_locales:
		language_dropdown.add_item(TranslationServer.get_locale_name(language))
