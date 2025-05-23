extends Node2D

var points := 0.0
# movement
var world_speed := 15.0 # rate at which things move towards bottom of screen
var speed := 100.0 # player's speed
var min_y := 0.20
var max_y := 0.80
var input_velocity: Vector2
var velocity: Vector2

var fuel := 0.0
var fuel_max := 20.0
var fuel_depletion_rate := 0.4
var fuel_recovery_rate := 0.2
var fuel_recovery_cooldown := 1.4
@onready var fuel_cooldown_timer := fuel_recovery_cooldown

@onready var screen_size := get_viewport_rect().size
@onready var player_size: Vector2 = $Area2D/Sprite2D.get_rect().size * $Area2D/Sprite2D.global_scale
@onready var doppel := $Area2D.duplicate()

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
	_process_missile()
	
func _process_input() -> void:
	velocity = Vector2.ZERO
	# Get Input
	input_velocity.x = Input.get_axis("move_left", "move_right")
	input_velocity.y = Input.get_action_strength("move_up")
	# normalize input
	if input_velocity.length() > 0:
		input_velocity = input_velocity.normalized()
		
func _process_movement(delta: float) -> void:
	var velocity_intent := input_velocity
	
	# process fuel
	if input_velocity.y <= 0.0:
		velocity_intent.y = 0.0
		if fuel_cooldown_timer > 0.0:
			fuel_cooldown_timer = maxf(fuel_cooldown_timer - delta, 0.0)
		else:
			fuel = minf(fuel + fuel_recovery_rate, fuel_max)
	elif input_velocity.y > 0.0:
		if fuel > 0.0:
			velocity_intent.y = -1.0
			fuel = maxf(fuel - fuel_depletion_rate, 0.0)
			fuel_cooldown_timer = fuel_recovery_cooldown
		else:
			velocity_intent.y = 0.0
	
	
	# Push player back owards bottom of screen
	if velocity_intent.y >= 0.0 and position.y / screen_size.y < (max_y - 0.005):
		velocity.y += world_speed
	velocity = Vector2(input_velocity.x * speed, (velocity_intent.y * 0.8) * speed) + velocity
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
