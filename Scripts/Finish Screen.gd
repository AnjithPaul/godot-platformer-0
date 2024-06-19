extends CanvasLayer

@onready var coin_count = $"Panel/MarginContainer2/GridContainer/coin count"
@onready var time_label = $Panel/MarginContainer2/GridContainer/time
@onready var highscore = $Panel/MarginContainer2/GridContainer/highscore
@onready var new_highscore_label = $"Panel/VBoxContainer/MarginContainer/new highscore"


func level_complete(coin, time, prev_highscore, is_new_highscore:bool):
	Engine.time_scale = 0
	self.visible = true
	coin_count.text = coin
	time_label.text = time
	highscore.text = prev_highscore
	if is_new_highscore:
		new_highscore_label.visible = true


func _on_button_pressed():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
