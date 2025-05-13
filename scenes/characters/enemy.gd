extends Area2D

@export var enemy_data: EnemyData

var health: float
var color_modulate_timer: float = 0.0

@onready var sprite := $Sprite2D

func _ready():
	if not enemy_data:
		printerr("EnemyData not assigned to", name, "!")
		queue_free()
		return
	
	# init
	health = enemy_data.health
	if enemy_data.sprite_texture:
		sprite.texture = enemy_data.sprite_texture

func _process(delta):
	position.y += 20.0 * delta
	if color_modulate_timer > 0.0:
		color_modulate_timer -= delta
		if color_modulate_timer <= 0.0:
			sprite.modulate = Color.WHITE

func damage(amount: float):
	health -= amount
	sprite.modulate = Color.BROWN
	color_modulate_timer = 0.15

	if health <= 0.0:
		queue_free()
