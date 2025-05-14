extends Node2D

var world_speed := 40.0 # rate at which things move towards bottom of screen
var speed := 100.0 # player's speed
var min_y := 0.20
var max_y := 0.80
var velocity : Vector2

@onready var screen_size := get_viewport_rect().size
@onready var player_size: Vector2 = $Area2D/Sprite2D.get_rect().size * $Area2D/Sprite2D.global_scale
@onready var dopple := $Area2D.duplicate()

# Bullet
#@onready var bullet := load("res://scenes/projectiles/simple_bullet.tscn")
@export var bullet : PackedScene
var shoot_cooldown := 0.2
var shoot_timer := shoot_cooldown

# Missile
@onready var hardpoints := $Hardpoints
@export var missile : PackedScene
var missile_cooldown := 1.0
var missile_timer := missile_cooldown
var max_missiles: int = 2
var readied_missiles : Array[Node]
var active_missile : Node
var do_aim_at_mouse := true

func _ready():
	# Set starting position
	position.x = screen_size.x / 2
	position.y = screen_size.y * max_y
	
	dopple.hide()
	add_child(dopple)

func _process(delta: float) -> void:
	process_movement(delta)
	process_bullet(delta)
	process_missile(delta)

func process_movement(delta: float) -> void:
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

func process_bullet(delta: float) -> void:
	shoot_timer -= delta

	if shoot_timer <= 0.0:
		shoot_timer = shoot_cooldown
		var n_bullet := 1
		for n in n_bullet:
			var a_bullet = bullet.instantiate()
			owner.add_child(a_bullet)

			var grid_offset = ((n_bullet - 1) * 2.0) - (n * 4.0)
			
			# setup rotation
			var angle := rotation
			a_bullet.rotation = angle
			# setup position
			a_bullet.position = position
			a_bullet.position.x -= grid_offset * sin(a_bullet.rotation)
			a_bullet.position.y -= grid_offset * cos(a_bullet.rotation)
			a_bullet.velocity = (Vector2(sin(angle), -cos(angle)) * a_bullet.speed) + (velocity / 8.0)
			
func process_missile(delta: float) -> void:
	missile_timer -= delta
	
	if Input.is_action_just_released("fire"):
		do_aim_at_mouse = false

	if missile_timer <= 0.0 and readied_missiles.size() < max_missiles:
		missile_timer = missile_cooldown
		# spawn readied missile with disabled collision
		var a_missile := missile.instantiate()
		var fill_attempt: bool = hardpoints.fill_slot(a_missile)
		print(fill_attempt)
		readied_missiles.push_back(a_missile)
		a_missile.monitoring = false
	
	if readied_missiles.size() > 0 and Input.is_action_just_pressed("fire"):
		do_aim_at_mouse = true
		active_missile = readied_missiles.pop_front()
		remove_child(active_missile)
		owner.add_child(active_missile)
		active_missile.monitoring = true

		var angle := rotation
		if do_aim_at_mouse:
			var m_pos := get_viewport().get_mouse_position()
			angle = atan2(m_pos.y - position.y, m_pos.x - position.x) + PI / 2
		active_missile.rotation = angle
		active_missile.position = position
		active_missile.velocity = (Vector2(sin(angle), -cos(angle)) * active_missile.speed) + (velocity / 8.0)
	
	if active_missile:
		if do_aim_at_mouse:
			var m_pos := get_viewport().get_mouse_position()
			var angle = atan2(m_pos.y - active_missile.position.y, m_pos.x - active_missile.position.x) + PI / 2
			active_missile.rotation = angle
			active_missile.velocity = (Vector2(sin(angle), -cos(angle)) * active_missile.speed)
			
		if Input.is_action_just_pressed("detonate"):
			active_missile.detonate()
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		print("ouch")
