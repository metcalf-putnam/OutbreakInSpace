extends Node

var state
var normal_db
var fade_time = 3
var menu_db 

var letters_sounds = [
	preload("res://dialog/letter-sounds/A Letter.wav"),
	preload("res://dialog/letter-sounds/B Letter.wav"),
	preload("res://dialog/letter-sounds/C Letter.wav"),
	preload("res://dialog/letter-sounds/D Letter.wav"),
	preload("res://dialog/letter-sounds/E Letter.wav"),
	preload("res://dialog/letter-sounds/F Letter.wav"),
	preload("res://dialog/letter-sounds/G Letter.wav"),
	preload("res://dialog/letter-sounds/H Letter.wav"),
	preload("res://dialog/letter-sounds/I Letter.wav"),
	preload("res://dialog/letter-sounds/J Letter.wav"),
	preload("res://dialog/letter-sounds/K Letter.wav"),
	preload("res://dialog/letter-sounds/L Letter.wav"),
	preload("res://dialog/letter-sounds/M Letter.wav"),
	preload("res://dialog/letter-sounds/N Letter.wav"),
	preload("res://dialog/letter-sounds/O Letter.wav"),
	preload("res://dialog/letter-sounds/P Letter.wav"),
	preload("res://dialog/letter-sounds/Q Letter.wav"),
	preload("res://dialog/letter-sounds/R Letter.wav"),
	preload("res://dialog/letter-sounds/S Letter.wav"),
	preload("res://dialog/letter-sounds/T Letter.wav"),
	preload("res://dialog/letter-sounds/U Letter.wav"),
	preload("res://dialog/letter-sounds/V Letter.wav"),
	preload("res://dialog/letter-sounds/W Letter.wav"),
	preload("res://dialog/letter-sounds/X Letter.wav"),
	preload("res://dialog/letter-sounds/Y Letter.wav"),
	preload("res://dialog/letter-sounds/Z Letter.wav")
]

func _ready():
	print("in music ready function")
	state = "normal"
	normal_db = $Players/MainIntro.volume_db
	menu_db = $Players/MenuLoop.volume_db
	
	


func change_state(new_state):
	state = new_state
	print("new music state: ", new_state)
	$Tween.stop_all()
	var audio_to_play : AudioStreamPlayer
	var volume 
	
	match new_state:
		"normal":
			audio_to_play = $Players/MainIntro
			volume = normal_db
		"menu":
			audio_to_play = $Players/MenuLoop
			volume = menu_db
		"none":
			fade_current()
			return

	for child in $Players.get_children():
		if child != audio_to_play:
			_set_fade_out(child) 
	$Tween.start() # Actually starts fading out
	
	if audio_to_play:
		audio_to_play.volume_db = volume
		if audio_to_play.is_playing():
			return
		else:
			audio_to_play.play()


func fade_current():
	print("fading current music")
	$Tween.stop_all()
	for child in $Players.get_children():
		_set_fade_out(child)
	$Tween.start() # Actually starts fading out
	state = "none"


func _on_MainIntro_finished():
	if state == "normal":
		$Players/MainLoop.play()
		$Players/MainLoop.volume_db = normal_db


func _set_fade_out(audio_player : AudioStreamPlayer):
	# Set Tween node to fade out one audio stream for a set amount of time
	# Tween needs to be started elsewhere, and may have issues if already tweening values
	if !audio_player.is_playing():
		return # Do nothing because that audio stream is not playing anything / can't fade out
	
	$Tween.interpolate_property(audio_player, "volume_db", audio_player.volume_db, -70, fade_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)


func _on_Tween_tween_all_completed():
	match state:
		"normal":
			$Players/MenuLoop.stop()
		"menu":
			$Players/MainIntro.stop()
			$Players/MainLoop.stop()
		"none":
			$Players/MainIntro.stop()
			$Players/MainLoop.stop()
			$Players/MenuLoop.stop()
	
