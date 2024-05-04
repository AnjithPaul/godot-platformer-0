extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -250.0
const COYOTE_TIME = 0.1  # Coyote time duration in seconds
const MAX_JUMP_TIME = 0.2  # Maximum time the jump button can be held down

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_pressed_time = 0.0
var leave_floor_time = 0.0
var can_jump = false

@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta):
	# Add gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle coyote time.
	if is_on_floor():
		leave_floor_time = 0.0
		can_jump = true 	
	else:
		if !Input.is_action_pressed("jump"):
			leave_floor_time += delta
		if leave_floor_time < COYOTE_TIME:
			can_jump = true
		else:
			can_jump = false

	# Update jump_pressed_time.
	if can_jump and Input.is_action_pressed("jump"):
		jump_pressed_time += delta
	else:
		jump_pressed_time = 0.0

	# Handle jump.
	if can_jump and Input.is_action_pressed("jump") and jump_pressed_time < MAX_JUMP_TIME:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")

	animated_sprite_2d.flip_h = direction < 0

	velocity.x = direction * SPEED
	move_and_slide()
