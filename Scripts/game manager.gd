extends Node

@onready var finish_screen = %"Finish Screen"
@onready var pause_button = %"Pause Button"
@onready var pause_menu = %"Pause Menu"
@onready var coins = $"../coins"

var score = 0
var level_time = 0.0
var finished = false
var fastest_time
var total_coins

const SAVE_PATH = "user://save_config_file.ini"

func _ready():
	level_time = 0.0
	finished = false
	#save_fastest_time(9999)	 # add to debug new higscore
	fastest_time = load_fastest_time()
	total_coins = coins.get_child_count()
	
	
func _process(delta: float):
	if Input.is_action_just_pressed("Pause"):
		toggle_pause()
		
	if !finished:
		level_time += delta


func add_point():
	score += 1


func finish_level():
	finished = true
	var is_new_highscore = false
	if (level_time < fastest_time):
		is_new_highscore = true
		fastest_time = level_time
		save_fastest_time(level_time)
	print(is_new_highscore)
	var time_hhmmss = get_hhmmss(level_time)
	var fastest_time_hhmmss = get_hhmmss(fastest_time)
	finish_screen.level_complete(str(score) + " / " + str(total_coins), time_hhmmss, fastest_time_hhmmss, is_new_highscore)


func get_hhmmss(time):
	var seconds:float = fmod(time , 60.0)
	var minutes:int   =  int(time / 60.0) % 60
	var hours:  int   =  int(time / 3600.0)
	var time_hhmmss = "%02d:%02d:%05.2f" % [hours, minutes, seconds]
	return time_hhmmss
	
	
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
	
	
func toggle_pause():
	pause_menu.visible = false if pause_menu.visible else true
	pause_button.visible = false if pause_menu.visible else true
	Engine.time_scale = 0 if Engine.time_scale == 1 else 1
