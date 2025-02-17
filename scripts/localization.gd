class_name Localization

const DEFAULT_LANGUAGE_LABEL = "SETTINGS_LANGUAGE_DEFAULT_LABEL"

var language_popup:PopupMenu = null # this has to be set externally

var language_map: Dictionary = {}
var available_locales = TranslationServer.get_loaded_locales()

func _init() -> void:
	for locale in available_locales:
		language_map[TranslationServer.get_locale_name(locale)] = locale


func set_initial_language() -> void:
	set_default_language()
	populate_dropdown()
	language_popup.index_pressed.connect(_on_locale_changed)


func populate_dropdown():
	language_popup.clear()
	language_popup.add_item(tr(DEFAULT_LANGUAGE_LABEL))
	for language in available_locales:
		language_popup.add_item(TranslationServer.get_locale_name(language))


func set_default_language():
	var os_lang = OS.get_locale_language()
	if os_lang in available_locales:
		TranslationServer.set_locale(os_lang)
	else:
		TranslationServer.set_locale("en")


func _on_locale_changed(index: int) -> void:
	var language = language_popup.get_item_text(index)
	if language == tr(DEFAULT_LANGUAGE_LABEL):
		set_default_language()
	else:
		TranslationServer.set_locale(language_map[language])
	populate_dropdown()
