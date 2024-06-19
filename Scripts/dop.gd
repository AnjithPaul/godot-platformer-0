extends Node2D

const X_OFFSET = 100
const LERP_SPEED = 1.0     # Object lerp speed (adjust for desired smoothness)

@onready var player = %Player
@onready var camera_2d = %camera

var screen_size
var y_offset
var t = 0.0


func _ready():
	screen_size = get_viewport_rect().size
	y_offset = screen_size.y / 6
	get_viewport().connect("size_changed", _on_viewport_resize)
	
func _on_viewport_resize():
	screen_size = get_viewport_rect().size
	y_offset = screen_size.y / 6



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var player_position = player.get_global_transform_with_canvas().origin
	var player_center_offset = player_position - screen_size / 2
	var y_deadzone = abs(player_center_offset.y) < y_offset
	var desired_position_y = self.position.y if y_deadzone else player.position.y
	var desired_position = Vector2 (player.position.x + X_OFFSET, desired_position_y)
	
	t += delta * LERP_SPEED
	
	position = position.lerp(desired_position, t)	
	set_position(desired_position)
