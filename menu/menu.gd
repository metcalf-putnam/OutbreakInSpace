extends Node2D

func _ready():
	$LanguageList.theme = Theme.new()
	$LanguageList.theme.default_font = DynamicFont.new()
	$LanguageList.theme.default_font.font_data = load("res://font/Awake.ttf")
	pass # Replace with function body.

func _on_LanguageList_item_selected(index):
	
	var locale = "en"
	match ($LanguageList.text):
		"Portuguese": locale = "pt"
	
	Global.selected_locale = locale
	pass # Replace with function body.
