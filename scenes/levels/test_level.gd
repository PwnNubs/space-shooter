extends Node2D

const simple_enemy_res = preload("res://resources/enemies/simple_enemy.tres")
var a_enemy := preload("res://scenes/characters/enemy.tscn")
var spawn_cooldown: float = 3.0
@onready var screen_size = get_viewport_rect().size

func _ready():
	# setup play zone, anything outiside of this should be deleted
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(screen_size.x * 1.5, screen_size.y * 1.5)
	collision_shape.shape = rect_shape
	area.add_child(collision_shape)
	area.position = screen_size / 2
	area.add_to_group("boundary")
	add_child(area)
	
	area.area_exited.connect(on_bounds_exited)
	

func _process(delta):
	spawn_cooldown -= delta
	if spawn_cooldown <= 0.0:
		var enemy := a_enemy.instantiate()
		add_child(enemy)
		enemy.enemy_data = simple_enemy_res
		enemy.position.x = randf_range(screen_size.x / 5, screen_size.x * 4 / 5)
		enemy.position.y = -20.0
		enemy.rotation = PI
		spawn_cooldown = 3.0

func on_bounds_exited(area):
	print(area)
	area.queue_free()
