extends CanvasLayer

@onready var game_manager = %game_manager

func _on_texture_button_pressed():
	game_manager.toggle_pause()
