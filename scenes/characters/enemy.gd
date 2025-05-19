extends Area2D

@export var enemy_data: EnemyData
@onready var health := Health.new()

var color_modulate_timer := 0.0

@onready var speed := 15.0 + randf() * 5.0
@onready var sprite := $Body

@onready var sway_speed := (randf() * 20.0) - 10.0

@onready var _explosion := $Explosion


@export var explosion_damage: float
@export var explosion_radius: float

func _ready():
	if not enemy_data:
		printerr("EnemyData not assigned to", name, "!")
		queue_free()
		return
	
	# init
	health.max_hp = enemy_data.hp
	health.hp = health.max_hp
	#if enemy_data.sprite_texture:
		#sprite.texture = enemy_data.sprite_texture
		
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
			sprite.modulate = Color.WHITE

	#rotation += rt

func damage(amount: float) -> void:
	if health.hp <= 0.0: # avoid possible infinite loop from stacking on death effects
		return
		
	health.hp -= amount
	var dmg_ratio := clampf(amount / health.max_hp, 0.0, 1.0)
	sprite.modulate = Color(1.0 - (dmg_ratio / 3.0), 1.0 - (dmg_ratio / 1.5), 1.0 - (dmg_ratio / 1.5))
	color_modulate_timer = clampf(0.3 * (dmg_ratio * dmg_ratio), 0.01, 0.3)
	
	if health.hp <= health.max_hp * 0.25:
		sprite.frame = 2
	elif health.hp <= health.max_hp * 0.8:
		sprite.frame = 1

	if health.hp <= 0.0:
		call_deferred("die")

func die() -> void:
	$Boomi.play()
	_explosion.trigger(global_position)
	sprite.play("death")
	$Engine.hide()
	monitorable = false
	await sprite.animation_finished
	queue_free()
