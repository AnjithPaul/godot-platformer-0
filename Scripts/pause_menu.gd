extends CanvasLayer
@onready var game_manager = %game_manager

func _on_resume_pressed():
	game_manager.toggle_pause()


func _on_quit_pressed():
	get_tree().quit()
