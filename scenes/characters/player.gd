extends Node2D

var world_speed := 40.0 # rate at which things move towards bottom of screen
var speed := 100.0 # player's speed
var min_y := 0.20
var max_y := 0.80

@onready var screen_size := get_viewport_rect().size
@onready var player_size: Vector2 = $Area2D/Sprite2D.get_rect().size * $Area2D/Sprite2D.global_scale

@onready var dopple := $Area2D.duplicate()

func _ready():
	# Set starting position
	position.x = screen_size.x / 2
	position.y = screen_size.y * max_y
	
	dopple.hide()
	add_child(dopple)

func _process(delta):
	process_movement(delta)
	
func process_movement(delta):
	var velocity := Vector2.ZERO
	
	# Get Input
	var input_velocity := Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		input_velocity.y -= 1
	# normalize input
	if input_velocity.length() > 0:
		input_velocity = input_velocity.normalized()
	
	# Push player back towards bottom of screen
	if input_velocity.y >= 0 && position.y / screen_size.y < max_y:
		velocity.y += world_speed
	
	# Actually move player
	position += ((input_velocity * speed) + velocity) * delta
	position.y = clamp(position.y, min_y * screen_size.y, max_y * screen_size.y)
	
	# wrapping
	position.x = wrapf(position.x, 0.0, screen_size.x)
	
	# visual wrapping
	var player_left := position.x - (player_size.x / 2)
	var player_right := position.x + (player_size.x / 2)
	if player_left < 0.0 && position.x > 0.0: # partially inside left wall
		dopple.position.x =   screen_size.x
		dopple.show()
	elif player_right > screen_size.x && position.x < screen_size.x: # partially inside right wall
		dopple.position.x = -screen_size.x
		dopple.show()
	else:
		dopple.hide()
