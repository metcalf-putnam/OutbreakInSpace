extends Node2D

export(String, FILE, "*.json") var dialog_file

onready var extract_scn = preload("res://bullet-prototype/misc/Extract.tscn")
onready var easy_virus_scn = preload("res://bullet-prototype/enemies/bearus/Bearus.tscn")
#onready var easy_virus_scn = preload("res://bullet-prototype/enemies/easy/Easy.tscn")
onready var player_scn = preload("res://bullet-prototype/player/prototype/Player.tscn")

onready var HUD = $CanvasLayer/HUD
onready var shield_icon_scn = preload("res://bullet-prototype/player/prototype/PlayerIcon.tscn")
onready var shield_container = $CanvasLayer/HUD/Shields
onready var ammo_icon_scn = preload("res://bullet-prototype/player/prototype/AmmoIcon.tscn")
onready var ammo_container = $CanvasLayer/HUD/Ammo
onready var extraction_points = $CanvasLayer/HUD/ExtractionPoints/ExtractionPointsValue
onready var extraction_points_tween = $CanvasLayer/HUD/ExtractionPoints/Tween
onready var time = $CanvasLayer/HUD/TimeValue

onready var status_value = $CanvasLayer/StageComplete/Panel/HBoxContainer/VBoxContainer/StatusValue
onready var details_value = $CanvasLayer/StageComplete/Panel/HBoxContainer/VBoxContainer/DetailsValue
onready var time_value = $CanvasLayer/StageComplete/Panel/HBoxContainer/VBoxContainer/TimeValue
onready var extraction_value = $CanvasLayer/StageComplete/Panel/HBoxContainer/VBoxContainer/ExtractionValue
onready var anim = $AnimationPlayer
onready var timer = $Timer

var current_player_settings
var is_stage_complete = false

enum STATE {DIALOGUE, BATTLE}
var state = STATE.DIALOGUE

var player
var virus

var started = false
var stage_time_now = 0
var elapsed
var seconds
var STAGE_TIMER = 60000

func display_stage_time():	
	elapsed = STAGE_TIMER - stage_time_now
	
	var milliseconds = clamp(elapsed % 1000, 0, 999)
	seconds = clamp(elapsed / 1000 % 60, 0, 59)
	var minutes = clamp(elapsed / 1000 / 60, 0, 59)
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	
	if milliseconds == 0 and seconds == 0 and minutes == 0:
		time.text = str_elapsed
		stage_complete("Extraction Complete!", "Fully utilized our machine!")
	else:
		time.text = str_elapsed

func add_shield():
	var shield_start_location = Vector2(110, 550)
	var shield_increment_location = Vector2(15, 0)
	for i in current_player_settings.shield:
		var shield = shield_icon_scn.instance()
		shield.position = Vector2(shield_start_location.x + (shield_increment_location.x * i), shield_start_location.y)
		shield_container.add_child(shield)
		yield(get_tree().create_timer(0.05), "timeout")

func add_ammo():
	var ammo_start_location = Vector2(975, 530)
	var ammo_increment_location = Vector2(15, 15)
	var y_modifier = 0
	for i in current_player_settings.ammo:
		var ammo = ammo_icon_scn.instance()
		
		if i % 20 == 0:
			y_modifier += 1
			
		ammo.position = Vector2(ammo_start_location.x - (ammo_increment_location.x * (i % 20)), ammo_start_location.y + (ammo_increment_location.y * y_modifier))
		ammo_container.add_child(ammo)
		ammo.pop()
		yield(get_tree().create_timer(0.05), "timeout")

func show_HUD():
	HUD.show()
	add_shield()
	add_ammo()

func add_player():
	var p = player_scn.instance()
	p.connect("fire", self, "_on_player_fire")
	p.connect("damage", self, "_on_player_damage")
	p.connect("stage_complete", self, "_on_stage_complete")
	p.connect("start_stage", self, "_on_start_stage")
	p.position = Vector2(750, 350)
	add_child(p)
	p.show()
	player = p

func add_virus(type = "EASY"):
	var v
	if type == "EASY":
		v = easy_virus_scn.instance()
		
	v.connect("extract", self, "_on_enemy_extract")
	v.connect("start_stage", self, "_on_start_stage")
	v.connect("stage_complete", self, "_on_stage_complete")
	v.position = Vector2(300, 200)
	add_child(v)
	v.show()
	virus = v
	
	yield(get_tree().create_timer(1), "timeout")

func stage_complete(status, details):
	started = false
	
	status_value.text = "\"" + status + "\""
	details_value.text = "\"" + details + "\""
	
	var value
	if status == "Extraction Complete!":
		if details == "Gnar eliminated the virus!":
			time_value.text = "\"Gnar defeated the virus in " + str(60-seconds) + " seconds!\""
			value = int(extraction_points.text) * 2 + 60
			pass
		elif details == "Fully utilized our machine!":
			time_value.text = "\"Gnar extracted a total of 1 minute!\""
			value = int(extraction_points.text) + 60
			pass
	else:
		time_value.text = "Extraction time in seconds: " + str(60-seconds)
		value = int(extraction_points.text) + (60-seconds)
		
	extraction_value.text = str(value)
	Global.player_settings.extraction_points += value
	
	player.hide()
	virus.hide()
	
	anim.play("stage_complete")

func _ready():
	current_player_settings = Global.player_settings
	EventHub.emit_signal("new_dialogue", dialog_file, "Assistant")
	EventHub.connect("dialogue_finished", self, "_on_dialogue_finished")
	pass # Replace with function body.

func _input(event):
	if !is_stage_complete: return
	
	if event is InputEventKey:
		if event.scancode == KEY_SPACE:
			get_tree().change_scene("res://root.tscn")

func _on_dialogue_finished():
	state = STATE.BATTLE
	
	show_HUD()
	add_virus()
	add_player()

func _on_player_fire():
	var index = ammo_container.get_child_count() - 1
	ammo_container.get_children()[index].queue_free()

func _on_player_damage():
	var index = shield_container.get_child_count() - 1
	shield_container.get_children()[index].queue_free()

func _on_stage_complete(status, details):
	stage_complete(status, details)
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "stage_complete":
		is_stage_complete = true
	pass # Replace with function body.

func _on_enemy_extract(type = "EASY"):
	var extraction_points = 0
	if type == "EASY":
		extraction_points += ceil(rand_range(0,3))
		
	for i in extraction_points:
		var extract = extract_scn.instance()
		extract.position = virus.position
		add_child(extract)
		
		var target_pos = virus.position + Vector2(rand_range(-50, 50), rand_range(-50, 50))
		var tween = Tween.new()
		tween.interpolate_property(extract, "position", target_pos, Vector2(240, 522), 0.5, Tween.TRANS_LINEAR,Tween.EASE_IN)
		add_child(tween)
		tween.start()
		tween.connect("tween_completed", self, "_on_extract_tween_completed")
		yield(tween, "tween_completed")

func _on_extract_tween_completed(object, key):
	object.queue_free()
	
	current_player_settings.extraction_points += 1
	extraction_points.text = str(current_player_settings.extraction_points)
	extraction_points_tween.interpolate_property(extraction_points, "rect_scale", Vector2(1,1), Vector2(2,2), 1, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	extraction_points_tween.interpolate_property(extraction_points, "rect_scale", Vector2(2,2), Vector2(1,1), 1, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	extraction_points_tween.start()

func _on_start_stage():
	if player.is_ready and virus.is_ready:
		player.can_move = true
		player.is_shoot_ready = true
		player.can_shoot = true
		
		started = true
		display_stage_time()
		timer.start()

func _on_Timer_timeout():
	if !started: return
	
	stage_time_now += 1000
	display_stage_time()
	timer.start()
	pass # Replace with function body.
