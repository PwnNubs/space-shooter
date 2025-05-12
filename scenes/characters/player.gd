extends Node2D

var world_speed := 40.0 # rate at which things move towards bottom of screen
var speed := 100.0 # player's speed
var min_y := 0.20
var max_y := 0.80
var velocity : Vector2

@onready var screen_size := get_viewport_rect().size
@onready var player_size: Vector2 = $Area2D/Sprite2D.get_rect().size * $Area2D/Sprite2D.global_scale
@onready var dopple := $Area2D.duplicate()
#@onready var bullet := load("res://scenes/projectiles/simple_bullet.tscn")
@export var bullet : PackedScene

var shoot_cooldown := 0.1
var cooldown := shoot_cooldown
var do_aim_at_mouse := true

func _ready():
	# Set starting position
	position.x = screen_size.x / 2
	position.y = screen_size.y * max_y
	
	dopple.hide()
	add_child(dopple)

func _process(delta):
	process_movement(delta)
	
	# shooting
	cooldown -= delta
	if cooldown <= 0.0:
		cooldown = shoot_cooldown
		var n_bullet := 1
		for n in n_bullet:
			var instance = bullet.instantiate()
			var grid_offset = ((n_bullet - 1) * 2.0) + (n * 4.0)
			owner.add_child(instance)
			
			# setup rotation
			var angle := rotation - PI/2
			if do_aim_at_mouse:
				var m_pos := get_viewport().get_mouse_position()
				angle = atan2(m_pos.y - position.y, m_pos.x - position.x)
			instance.rotation = angle
			# setup position
			instance.position = position
			instance.position.x -= grid_offset * sin(instance.rotation)
			instance.position.y -= grid_offset * cos(instance.rotation)
			instance.velocity = (Vector2(cos(instance.rotation), sin(instance.rotation)) * instance.speed) + (velocity / 8.0)
	
func process_movement(delta):
	velocity = Vector2.ZERO
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
	if input_velocity.y >= 0 and position.y / screen_size.y < (max_y - 0.005):
		velocity.y += world_speed
	velocity = (input_velocity * speed) + velocity
	# Actually move player
	position += velocity * delta
	position.y = clamp(position.y, min_y * screen_size.y, max_y * screen_size.y)
	
	# wrapping
	position.x = wrapf(position.x, 0.0, screen_size.x)
	
	# visual wrapping
	var player_left := position.x - (player_size.x / 2)
	var player_right := position.x + (player_size.x / 2)
	if player_left < 0.0 and position.x > 0.0: # partially inside left wall
		dopple.position.x =   screen_size.x
		dopple.show()
	elif player_right > screen_size.x and position.x < screen_size.x: # partially inside right wall
		dopple.position.x = -screen_size.x
		dopple.show()
	else:
		dopple.hide()
