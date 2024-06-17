extends CharacterBody2D

const SPEED = 130.0
const MIN_SPEED = 120.0
const MAX_SPEED = 150.0
const ACCELERATION_TIME = 0.5
const JUMP_VELOCITY = -250.0
const COYOTE_TIME = 0.1  # Coyote time duration in seconds
const MAX_JUMP_TIME = 0.2  # Maximum time the jump button can be held down
const MIN_DRAG_DIST = 10

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_pressed_time = 0.0
var leave_floor_time = 0.0
var can_jump = false
var is_jump = false
var speed = MIN_SPEED
var previous_direction
var coyote_enabled
var direction = 0
var is_dragging = false
var ini_pos
var drag_index
var drag_index_validity = false
var drag_dist = Vector2.ZERO
var jump_index
var jump_index_validty = false
var screen_mid

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var touch_controls = %"Touch Controls"
@onready var camera = %camera

func _ready():
	screen_mid = get_viewport_rect().get_center().x
	
func _physics_process(delta):

	print("jump validity: ", jump_index_validty)
	#if(is_jump):
		#print("jumping...")
	#if(can_jump):
		#print("Can jump")
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
		leave_floor_time += delta
		if leave_floor_time < COYOTE_TIME:
			can_jump = true
		else:
			can_jump = false

	# Handle jump.
	if can_jump and get_jump() and jump_pressed_time < MAX_JUMP_TIME:
		velocity.y = JUMP_VELOCITY
		#print("jumping")
		if jump_pressed_time == 0.0:
			animation_player.play("jump")
		coyote_enabled = false
		
	#if jump_pressed_time > MAX_JUMP_TIME:
		#print("jump time over")
	
	# Update jump_pressed_time.
	if can_jump and get_jump():
		jump_pressed_time += delta
		
	if Input.is_action_just_released("jump"):
		can_jump = false
		#print("can't jump")

	## Get the input direction and handle the movement/deceleration.
	var direction = get_direction()
	#direction = sign(drag_dist.x) if abs(drag_dist.x) > MIN_DRAG_DIST else 0

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
	
	
	
	
func _input(event):
	var elsy = true
	var is_drag = event is InputEventScreenDrag
	
	if event is InputEventScreenTouch:
		elsy = false
		#print("touching")
		#print("touch position:", event.position)
		if event.is_pressed():
			if !drag_index_validity and event.position.x < screen_mid:
				drag_index = event.index
				drag_index_validity = true
				ini_pos = event.position
				#print("drag index detected")
			elif !jump_index_validty and event.position.x > screen_mid:
				jump_index = event.index
				jump_index_validty = true
				is_jump = true
				#print("event position:", event.position.x)
				#print("screen center:", screen_mid)
				#print("jump index detected")
			else:
				jump_index_validty = false
				print("else block")
				#print("drag index validty", drag_index_validity)
				print("jump index validty: ", jump_index_validty)
		else:
			match event.index:
				drag_index:
					drag_index_validity = false
					drag_dist = Vector2.ZERO
				jump_index:
					print("jump not pressed")
					jump_index_validty = false
					is_jump = false
					can_jump = false
					#print("can't jump")
					
	if event is InputEventScreenDrag:
		elsy = false
		#print("drag index: ", event.index)
		if event.index == drag_index and drag_index_validity:
			#print ("dragging")
			#if !is_dragging:
				#ini_pos = event.position
				#is_dragging = true
			#else:
			
			drag_dist = event.position - ini_pos
			#direction = sign(drag_dist.x) if abs(drag_dist.x) > MIN_DRAG_DIST else 0
		elif event.index == jump_index:
			print("jump dragging")
			#jump_index_validty = false
		#print(ini_pos)
		#print(event.position)
		#print(direction)

			
		
		#var touch_index = event.index
		#if (event.pressed and event.index == touch_index and event.position.x > camera.get_screen_center_position().x) or Input.is_action_pressed("jump"):
			#is_jump = true
	if !is_drag and !event.is_pressed() and !(event is InputEventMouseMotion or event is InputEventMouseButton or event is InputEventKey):
		elsy = false
		match event.index:
			drag_index:
				direction = 0
				drag_index_validity = false
				drag_dist = Vector2.ZERO
			jump_index:
				is_jump = false
				print("jump released")
				jump_index_validty = false
				can_jump = false
				#print("can't jump")
	if elsy and !(event is InputEventMouseMotion or event is InputEventMouseButton or event is InputEventKey):
		if event.index == jump_index:
			print("elsy")
			jump_index_validty = false
		
#func jump():
	#if can_jump and jump_pressed_time < MAX_JUMP_TIME:
		#velocity.y = JUMP_VELOCITY
		#if jump_pressed_time == 0.0:
			#animation_player.play("jump")
		#coyote_enabled = false

func get_direction():
	return sign(sign(drag_dist.x) if abs(drag_dist.x) > MIN_DRAG_DIST else 0 + Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	
func get_jump():
	return Input.is_action_pressed("jump") or jump_index_validty
