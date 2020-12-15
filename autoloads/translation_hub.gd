extends Node

# Language Settings
const DEFAULT_LOCALE = "en"
var selected_locale = "en"

# oip_strings.csv - KEYS and this const KEYS should have the same values
const KEYS = {
	"START": "START",
	"LANGUAGE": "LANGUAGE",
	"ENGLISH": "ENGLISH"
}


func get_translated_file(dialog_file):
	var file = File.new()
	if selected_locale != DEFAULT_LOCALE:
		var filename = dialog_file.substr(dialog_file.find_last("/") + 1)
		var path = "res://dialog/json/" + selected_locale + "/" + filename
		
		# if there is no existing translation use default "en"
		if not file.file_exists(path):
			return dialog_file
		return path
	
	return dialog_file


func set_locale(locale):
	selected_locale = locale
	
	# tr() will use the locale set to translation server 
	TranslationServer.set_locale(selected_locale)
