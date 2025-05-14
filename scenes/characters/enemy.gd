extends Area2D

@export var enemy_data: EnemyData

var max_health: float
var health: float
var color_modulate_timer: float = 0.0

@onready var rt := (randf() - 0.5) / 20.0
@onready var sprite := $Sprite2D

func _ready():
	if not enemy_data:
		printerr("EnemyData not assigned to", name, "!")
		queue_free()
		return
	
	# init
	max_health = enemy_data.max_health * randf()
	health = max_health
	if enemy_data.sprite_texture:
		sprite.texture = enemy_data.sprite_texture

func _process(delta: float) -> void:
	position.y += 30.0 * delta
	if color_modulate_timer > 0.0:
		color_modulate_timer -= delta
		if color_modulate_timer <= 0.0:
			sprite.modulate = Color.WHITE
	
	#rotation += rt

func damage(amount: float) -> void:
	health -= amount
	var dmg_ratio := clampf(amount / max_health, 0.0, 1.0)
	sprite.modulate = Color(1.0 - (dmg_ratio / 3.0), 1.0 - (dmg_ratio / 1.5), 1.0 - (dmg_ratio / 1.5))
	color_modulate_timer = clampf(0.3 * (dmg_ratio * dmg_ratio), 0.01, 0.3)

	if health <= 0.0:
		queue_free()
