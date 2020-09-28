extends Node

var state
var normal_db
var fighting_db
var fade_time = 5

func _ready():
	print("in music ready function")
	state = "normal"
	normal_db = $Players/MainIntro.volume_db
	fighting_db = $Players/FightingIntro.volume_db


func change_state(new_state):
	state = new_state
	print("new music state: ", new_state)
	$Tween.stop_all()
	var audio_to_play : AudioStreamPlayer
	var volume 
	if new_state == "normal":
		audio_to_play = $Players/MainIntro
		volume = normal_db
	if new_state == "fighting":
		audio_to_play = $Players/FightingIntro
		volume = fighting_db
	for child in $Players.get_children():
		if child != audio_to_play:
			_set_fade_out(child) 
	$Tween.start() # Actually starts fading out
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


func _on_MainIntro_finished():
	if state == "normal":
		$Players/MainLoop.volume_db = normal_db
		$MainLoop.play()


func _on_FightingIntro_finished():
	if state == "fighting":
		$Players/FightingLoop.volume_db = fighting_db
		$FightingLoop.play()


func _set_fade_out(audio_player : AudioStreamPlayer):
	# Set Tween node to fade out one audio stream for a set amount of time
	# Tween needs to be started elsewhere, and may have issues if already tweening values
	if !audio_player.is_playing():
		return # Do nothing because that audio stream is not playing anything / can't fade out
	
	$Tween.interpolate_property(audio_player, "volume_db", audio_player.volume_db, -60, fade_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)


func _on_Tween_tween_all_completed():
	if state == "normal":
		$Players/FightingIntro.stop()
		$Players/FightingLoop.stop()
	if state == "fighting":
		$Players/MainIntro.stop()
		$Players/MainLoop.stop()
