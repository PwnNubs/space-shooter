extends Area2D

@export var explosion_scene: PackedScene

@export var enemy_data: EnemyData
@onready var health := Health.new()

var color_modulate_timer: float = 0.0

@onready var rt := (randf() - 0.5) / 20.0
@onready var speed := 15.0 + randf() * 15.0
@onready var sprite := $Sprite2D

func _ready():
	if not enemy_data:
		printerr("EnemyData not assigned to", name, "!")
		queue_free()
		return
	
	# init
	health.max_hp = enemy_data.max_health * randf()
	health.hp = health.max_hp
	if enemy_data.sprite_texture:
		sprite.texture = enemy_data.sprite_texture

func _physics_process(delta: float) -> void:
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

	if health.hp <= 0.0:
		call_deferred("die")

func die() -> void:
	var explosion := explosion_scene.instantiate()
	explosion.damage = 2.0
	explosion.radius = 10.0
	get_parent().add_child(explosion)
	explosion.trigger(global_position)
	queue_free()
