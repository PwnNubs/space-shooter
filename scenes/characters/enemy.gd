extends RigidBody2D

@export var enemy_data: EnemyData
@onready var health := Health.new()

var color_modulate_timer := 0.0

@onready var speed := 15.0 + randf() * 5.0

@onready var sway_speed := (randf() * 20.0) - 10.0

@onready var _boomi := $Boomi
@onready var _explosion := $Explosion
@onready var _body := $Body
@onready var _engine := $Engine

func _ready():
	if not enemy_data:
		printerr("EnemyData not assigned to", name, "!")
		queue_free()
		return
	
	# init
	health.max_hp = enemy_data.hp
	health.hp = health.max_hp
	#if enemy_data.sprite_texture:
		#$Body.texture = enemy_data.sprite_texture
		
	$Engine.play()

func _physics_process(delta: float) -> void:
	if 0.01 >= randf():
		sway_speed = -sway_speed
		
	position.x += sway_speed * delta
	position.y += speed * delta
	#global_position.round()
	if color_modulate_timer > 0.0:
		color_modulate_timer -= delta
		if color_modulate_timer <= 0.0:
			$Body.modulate = Color.WHITE

	#rotation += rt

func damage(amount: float) -> void:
	if health.hp <= 0.0: # avoid possible infinite loop from stacking on death effects
		return
		
	health.hp -= amount
	var dmg_ratio := clampf(amount / health.max_hp, 0.0, 1.0)
	$Body.modulate = Color(1.0 - (dmg_ratio / 3.0), 1.0 - (dmg_ratio / 1.5), 1.0 - (dmg_ratio / 1.5))
	color_modulate_timer = clampf(0.3 * (dmg_ratio * dmg_ratio), 0.01, 0.3)
	
	if health.hp <= health.max_hp * 0.25:
		$Body.frame = 2
	elif health.hp <= health.max_hp * 0.8:
		$Body.frame = 1

	if health.hp <= 0.0:
		die()

func die() -> void:
	get_tree().get_first_node_in_group("EnemyLayer").kill_count += 1
	_explosion.trigger()
	await get_tree().physics_frame
	_boomi.play()
	_body.play("death")
	_engine.hide()
	#collision_layer = 10
	# remove collision
	#for collision_shape in find_children("*", "CollisionShape2D"):
		#collision_shape.set_deferred("disabled", true)
	 # messes with stuff
	#$CollisionShape2D.disabled = true
	$CollisionShape2D.queue_free()
	await _body.animation_finished
	queue_free()
