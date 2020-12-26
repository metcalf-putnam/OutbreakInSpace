extends Node

var logs = []

enum LOG_TYPE { NPC_INTERACTION, TESTING }


func create_log_for(who, log_type):
	var log_value = ""
	if log_type == LOG_TYPE.NPC_INTERACTION:
		log_value = "%s > Day %d: Talked to [color=red]%s[/color]\n" % [ get_time(), Global.day, who]
	else:
		log_value = "%s > Day %d: Tested [color=yellow]%s[/color]\n" % [ get_time(), Global.day, who]
	
	add_log(log_value)


func add_log(value):
	logs.append(value)


func get_logs():
	return logs


func get_log_count():
	return logs.size()


func reset():
	logs = []


func get_time() -> String:
	var time = OS.get_time()
	return "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
