class_name Localization

var language_popup = null # this has to be set externally

var language_map: Dictionary = {}
var available_locales = TranslationServer.get_loaded_locales()

func _init() -> void:
	var available_locales = TranslationServer.get_loaded_locales()
	for locale in available_locales:
		language_map[TranslationServer.get_locale_name(locale)] = locale


func set_initial_language() -> void:
	if OS.get_locale_language() in available_locales:
		TranslationServer.set_locale(OS.get_locale_language())
	for language in available_locales:
		language_popup.add_item(TranslationServer.get_locale_name(language))
	language_popup.index_pressed.connect(_on_locale_changed)


func _on_locale_changed(index: int) -> void:
	var language = language_popup.get_item_text(index)
	TranslationServer.set_locale(language_map[language])
