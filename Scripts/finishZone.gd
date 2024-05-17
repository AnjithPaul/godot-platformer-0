extends Area2D

@onready var game_manager = %game_manager
@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	print(body.name)
	if body.name == "Player":
		print("You've won")
		animation_player.play("finish_flag")
		game_manager.finish_level() 
