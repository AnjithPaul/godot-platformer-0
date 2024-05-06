extends CharacterBody2D

const SPEED = 130.0
const MIN_SPEED = 120.0
const MAX_SPEED = 150.0
const ACCELERATION_TIME = 0.5
const JUMP_VELOCITY = -250.0
const COYOTE_TIME = 0.1  # Coyote time duration in seconds
const MAX_JUMP_TIME = 0.2  # Maximum time the jump button can be held down

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_pressed_time = 0.0
var leave_floor_time = 0.0
var can_jump = false
var speed = MIN_SPEED
var previous_direction
var coyote_enabled

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

func _physics_process(delta):
	# Add gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle coyote time.
	if is_on_floor():
		leave_floor_time = 0.0
		jump_pressed_time = 0.0
		can_jump = true
		coyote_enabled = true 
	elif coyote_enabled:
		print("increasing coyote time")
		leave_floor_time += delta
		if leave_floor_time < COYOTE_TIME:
			can_jump = true
		else:
			can_jump = false

	# Update jump_pressed_time.
	if can_jump and Input.is_action_pressed("jump"):
		jump_pressed_time += delta
		print(jump_pressed_time)

	# Handle jump.
	if can_jump and Input.is_action_pressed("jump") and jump_pressed_time < MAX_JUMP_TIME:
		velocity.y = JUMP_VELOCITY
		animation_player.play("jump")
		coyote_enabled = false
		
	if Input.is_action_just_released("jump"):
		can_jump = false

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

	#Handle Velocity
	var acceleration = (MAX_SPEED - MIN_SPEED) / ACCELERATION_TIME

	if direction != previous_direction or direction == 0:
		speed = MIN_SPEED
	else:
		speed += acceleration * delta if speed < MAX_SPEED else 0
	previous_direction = direction
	velocity.x = direction * speed
	move_and_slide()
