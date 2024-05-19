extends Node2D

var min_length = 100
var start_pos: Vector2
var current_pos: Vector2 
var is_swiping = false
var direction_vector: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("touch"):
		if !is_swiping:
			is_swiping = true
			start_pos = get_global_mouse_position()
			print("Start Position: ", start_pos)
			
	elif Input.is_action_pressed("touch"):
		if is_swiping:
			current_pos = get_global_mouse_position()
			if start_pos.distance_to(current_pos) >= min_length:
				print("Swipe detected")
				direction_vector = current_pos - start_pos
				#is_swiping = false
	else:
		is_swiping= false
		direction_vector = Vector2.ZERO
	
	
func get_swipe_direction():
	return sign(direction_vector.x)
