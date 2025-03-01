class_name Localization

const DEFAULT_LANGUAGE_LABEL = "SETTINGS_LANGUAGE_DEFAULT_LABEL"

var language_dropdown: OptionButton = null # this has to be set externally
var language_popup: PopupMenu = null

var language_map: Dictionary = {}
var available_locales = TranslationServer.get_loaded_locales()

func _init() -> void:
	for locale in available_locales:
		language_map[TranslationServer.get_locale_name(locale)] = locale


func set_initial_language() -> void:
	language_popup = language_dropdown.get_popup()
	set_default_language()
	_populate_dropdown()
	language_popup.index_pressed.connect(_on_locale_changed)


func set_default_language():
	var os_lang = OS.get_locale_language()
	if os_lang in available_locales:
		TranslationServer.set_locale(os_lang)
	else:
		TranslationServer.set_locale("en")


func set_locale(locale: String):
	TranslationServer.set_locale(locale)
	var language = TranslationServer.get_locale_name(locale)
	for i in range(language_popup.item_count):
		if language == language_popup.get_item_text(i):
			language_dropdown.selected = i
			return


func _on_locale_changed(index: int) -> void:
	var language = language_popup.get_item_text(index)
	if language == tr(DEFAULT_LANGUAGE_LABEL):
		set_default_language()
	else:
		TranslationServer.set_locale(language_map[language])
	_populate_dropdown()

func _populate_dropdown():
	language_popup.clear()
	language_popup.add_item(tr(DEFAULT_LANGUAGE_LABEL))
	for language in available_locales:
		language_popup.add_item(TranslationServer.get_locale_name(language))
