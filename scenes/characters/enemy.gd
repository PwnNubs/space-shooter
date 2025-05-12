extends Area2D

@export var enemy_data: EnemyData

var health: float

@onready var sprite := $Sprite2D

func _ready():
	print(enemy_data)
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

	if health <= 0.0:
		queue_free()
