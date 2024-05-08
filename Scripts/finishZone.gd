extends Area2D

@onready var game_manager = %game_manager
@onready var player = %Player

func _on_body_entered(body):
	print(body.name)
	if body.name == "Player":
		print("You've won")
		game_manager.finish_level() 
