extends Node2D

# movement
var world_speed := 40.0 # rate at which things move towards bottom of screen
var speed := 100.0 # player's speed
var min_y := 0.20
var max_y := 0.80
var input_velocity : Vector2
var velocity : Vector2

@onready var screen_size := get_viewport_rect().size
@onready var player_size: Vector2 = $Area2D/Sprite2D.get_rect().size * $Area2D/Sprite2D.global_scale
@onready var doppel := $Area2D.duplicate()

# Bullet
#@onready var bullet := load("res://scenes/projectiles/simple_bullet.tscn")
@export var bullet : PackedScene
var shoot_cooldown := 0.8#0.8
var shoot_timer := shoot_cooldown

# Missile
@onready var hardpoints := $Hardpoints
@export var missile : PackedScene
var missile_cooldown := 2.0
var readied_missiles : Array[Node]
var active_missile : Node
var do_aim_at_mouse := true

func _ready():
	# Set starting position
	position.x = screen_size.x / 2
	position.y = screen_size.y * max_y
	
	doppel.hide()
	add_child(doppel)
	
	hardpoints.cooldown = missile_cooldown
	
func _process(_delta: float) -> void:
	_process_input()

func _physics_process(delta: float) -> void:
	_process_movement(delta)
	_process_shoot(delta)
	_process_missile()
	
func _process_input() -> void:
	velocity = Vector2.ZERO
	# Get Input
	input_velocity.x = Input.get_axis("move_left", "move_right")
	input_velocity.y = -Input.get_action_strength("move_up")
	# normalize input
	if input_velocity.length() > 0:
		input_velocity = input_velocity.normalized()
		
	# debug
	if Input.is_action_just_pressed("debug"):
		print(owner.get_child_count())
		
func _process_movement(delta: float) -> void:
	# Push player back owards bottom of screen
	if input_velocity.y >= 0 and position.y / screen_size.y < (max_y - 0.005):
		velocity.y += world_speed
	velocity = Vector2(input_velocity.x * speed, input_velocity.y * speed / 2) + velocity
	# Actually move player
	position += velocity * delta
	position.y = clamp(position.y, min_y * screen_size.y, max_y * screen_size.y)
	
	# wrapping
	position.x = wrapf(position.x, 0.0, screen_size.x)
	
	# visual wrapping
	# !!!!!! BUGGED !!!!!!!!!
	# sometimes doppel just gets removed
	if doppel:
		var player_left := position.x - (player_size.x / 2)
		var player_right := position.x + (player_size.x / 2)
		if player_left < 0.0 and position.x > 0.0: # partially inside left wall
			doppel.position.x = screen_size.x
			doppel.show()
		elif player_right > screen_size.x and position.x < screen_size.x: # partially inside right wall
			doppel.position.x = -screen_size.x
			doppel.show()
		else:
			doppel.hide()
	else:
		doppel = $Area2D.duplicate()
		doppel.hide()
		add_child(doppel)

func _process_shoot(delta: float) -> void:
	shoot_timer -= delta
	if shoot_timer > 0.0:
		return

	shoot_timer = shoot_cooldown
	var n_bullet := 2
	var spacing := 10.0
	for n in n_bullet:
		var a_bullet = bullet.instantiate()
		owner.add_child(a_bullet)

		var grid_offset = ((n_bullet - 1) * (spacing / 2)) - (n * spacing)
		
		# setup rotation
		var angle := rotation
		a_bullet.rotation = angle
		# setup position
		a_bullet.position = position
		a_bullet.position.x -= grid_offset * cos(a_bullet.rotation)
		a_bullet.position.y -= grid_offset * sin(a_bullet.rotation)
		a_bullet.velocity = (Vector2.from_angle(angle - PI / 2) * a_bullet.speed) + (velocity / 8.0)#(Vector2(sin(angle), -cos(angle)) * a_bullet.speed) + (velocity / 8.0)
		
func _process_missile() -> void:
	if Input.is_action_just_released("fire"):
		do_aim_at_mouse = false
		
	if not hardpoints.check_empty() and Input.is_action_just_pressed("fire"):
		do_aim_at_mouse = true
		active_missile = hardpoints.release_a_slot()
		var missile_layer = owner.find_child("MissileLayer")
		if not missile_layer:
			printerr("MissileLayer was not found for ", owner)
			active_missile.queue_free()
			return
		else:
			missile_layer.add_child(active_missile)
		active_missile.monitoring = true

		var angle := rotation
		if do_aim_at_mouse:
			var m_pos := get_viewport().get_mouse_position()
			angle = atan2(m_pos.y - position.y, m_pos.x - position.x) + PI / 2
		active_missile.rotation = angle
		active_missile.velocity = (Vector2(sin(angle), -cos(angle)) * active_missile.speed) + (velocity / 8.0)
	
	if active_missile:
		if do_aim_at_mouse:
			var m_pos := get_viewport().get_mouse_position()
			var angle = atan2(m_pos.y - active_missile.position.y, m_pos.x - active_missile.position.x) + PI / 2
			var angle_diff = angle_difference(active_missile.rotation, angle)
			
			angle_diff = clampf(angle_diff, -active_missile.turn_limit, active_missile.turn_limit)
			active_missile.rotation += angle_diff
			active_missile.velocity = (Vector2(sin(active_missile.rotation), -cos(active_missile.rotation)) * active_missile.speed)
			
		if Input.is_action_just_pressed("detonate"):
			active_missile.detonate()
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		pass #print("ouch")


func _on_hardpoints_request_refill(index: int) -> void:
	# spawn readied missile with disabled collision
	var a_missile := missile.instantiate()
	hardpoints.fill_slot(a_missile, index)
	a_missile.monitoring = false
