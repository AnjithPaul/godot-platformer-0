extends Node

@onready var score_label = $score_label
@onready var time_label = $time_label
@onready var highscore = $highscore
@onready var timer = $Timer
var score = 0
var level_time = 0.0
var finished = false
var fastest_time

const SAVE_PATH = "user://save_config_file.ini"

func _ready():
	level_time = 0.0
	finished = false
	fastest_time = load_fastest_time()
	#print(fastest_time)
	#save_fastest_time(999999)
	#print(load_fastest_time())
	var seconds:float = fmod(fastest_time , 60.0)
	var minutes:int   =  int(fastest_time / 60.0) % 60
	var hours:  int   =  int(fastest_time / 3600.0)
	var hs_hhmmss_string:String = "%02d:%02d:%05.2f" % [hours, minutes, seconds]
	highscore.text = "Your fastest time so far: " + hs_hhmmss_string
	highscore.visible = false
	time_label.visible = false
	
	
func _process(delta: float):
	if !finished:
		level_time += delta
	var seconds:float = fmod(level_time , 60.0)
	var minutes:int   =  int(level_time / 60.0) % 60
	var hours:  int   =  int(level_time / 3600.0)
	var hhmmss_string:String = "%02d:%02d:%05.2f" % [hours, minutes, seconds]
	
	time_label.text = "Congrats! You have finished the level in " + hhmmss_string

func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + "coins."

func finish_level():
	finished = true
	if (level_time < fastest_time):
		save_fastest_time(level_time)
		highscore.text = "NEW RECORD TIME !!!"
		highscore.add_theme_font_size_override("font_size",16)
		print("NEW HIGHSCORE")
	highscore.visible = true
	time_label.visible = true
	timer.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()

func save_fastest_time(time):
	var config = ConfigFile.new()
	config.set_value("player", "fastest_time", time)
	config.save(SAVE_PATH)
	
func load_fastest_time():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return 9999999
	return config.get_value("player", "fastest_time")
