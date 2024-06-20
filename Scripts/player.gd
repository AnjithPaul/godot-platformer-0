extends CharacterBody2D

const MIN_SPEED = 120.0 # Minimum speed of the player
const MAX_SPEED = 150.0 # Maximum speed of the player
const ACCELERATION_TIME = 0.5 # Time required to achieve maximum speed
const JUMP_VELOCITY = -250.0 # Vertical velocity during jump
const COYOTE_TIME = 0.1  # Coyote time duration in seconds
const MAX_JUMP_TIME = 0.2  # Maximum time the jump button can be held down
const MIN_DRAG_DIST = 10 # Minium distance to touch and drag to get detected

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#jump
var jump_pressed_time = 0.0 # Total time the jump button is held down
var leave_floor_time = 0.0 # Time since the player last touched floor when not jumping
var can_jump = false # Whether player can jump based on coyote time and jump button release.
var coyote_enabled # Whether player is in coyote time

#movement
var speed = MIN_SPEED # Current speed of player
var direction = 0 # Current direction of the player
var previous_direction # Previous direction of the player

#touch input
var ini_pos # Starting position of the touch drag
var move_index # Index of touch event in case of movement
var move_index_validity = false # Whether the movement touch is still active
var move_dist = Vector2.ZERO # Total distance dragged by movement touch
var jump_index # Index of touch event in case of jump
var jump_index_validity = false # Whether the jump touch is still active
var screen_mid # Center coordinates of the screen based on screen resolution
var frame_delta # delta of physics process

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var touch_controls = %"Touch Controls"
@onready var camera = %camera

func _ready():
	screen_mid = get_viewport_rect().get_center().x
	
func _physics_process(delta):
	frame_delta = delta

	## Handle gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	## Handle coyote time
	if is_on_floor():
		leave_floor_time = 0.0
		jump_pressed_time = 0.0
		can_jump = true
		coyote_enabled = true 
	elif coyote_enabled:
		leave_floor_time += delta
		if leave_floor_time < COYOTE_TIME:
			can_jump = true
		else:
			can_jump = false

	## Handle jump
	if get_jump():
		jump()
	if Input.is_action_just_released("jump"):
		can_jump = false

	## Handle movement direction
	var direction = get_direction()

	## Handle animation
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")

	animated_sprite_2d.flip_h = direction < 0

	## Handle Velocity
	var acceleration = (MAX_SPEED - MIN_SPEED) / ACCELERATION_TIME
	if direction != previous_direction or direction == 0:
		speed = MIN_SPEED
	else:
		speed += acceleration * delta if speed < MAX_SPEED else 0
	previous_direction = direction
	velocity.x = direction * speed
	move_and_slide()
	
	
	
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if !move_index_validity and event.position.x < screen_mid:
				move_index = event.index
				move_index_validity = true
				ini_pos = event.position
			if !jump_index_validity and event.position.x > screen_mid:
				jump_index = event.index
				jump_index_validity = true
				jump()
		else:
			if event.index == move_index:
				move_index_validity = false
				move_dist = Vector2.ZERO
			if event.index == jump_index:
				jump_index_validity = false
				can_jump = false

	if event is InputEventScreenDrag:
		if event.index == move_index and move_index_validity:
			move_dist = event.position - ini_pos
		if event.index == jump_index:
			jump()


func jump():
	if !can_jump:
		return
	if jump_pressed_time < MAX_JUMP_TIME:
		velocity.y = JUMP_VELOCITY
		if jump_pressed_time == 0.0:
			animation_player.play("jump")
		coyote_enabled = false
	jump_pressed_time += frame_delta


func get_direction():
	return sign(sign(move_dist.x) if abs(move_dist.x) > MIN_DRAG_DIST else 0 + Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))


func get_jump():
	return Input.is_action_pressed("jump") or jump_index_validity
