extends Node2D

const simple_enemy_res = preload("res://resources/enemies/simple_enemy.tres")
var a_enemy := preload("res://scenes/characters/enemy.tscn")
var spawn_cooldown: float = 0.01#0.6#0.01#1.5 0.05
var spawn_timer: float = spawn_cooldown
@onready var screen_size = get_viewport_rect().size

func _ready():
	#get_tree().debug_collisions_hint = true
	
	# setup play zone, anything outiside of this should be deleted
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(screen_size.x * 1.5, screen_size.y * 1.5)
	collision_shape.shape = rect_shape
	area.add_child(collision_shape)
	area.position = screen_size / 2
	area.add_to_group("boundary")
	area.monitorable = false
	area.monitoring = true
	area.collision_mask = 0b1111
	add_child(area)
	
	area.area_exited.connect(on_bounds_exited)
	area.body_exited.connect(on_bounds_exited)
	
	$Player/AudioListener2D.make_current()

func _process(delta):
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		for _n in 1:
			var enemy := a_enemy.instantiate()
			$EnemyLayer.add_child(enemy)
			enemy.enemy_data = simple_enemy_res
			enemy.position.x = randf_range(screen_size.x * 0.0, screen_size.x * 1.0)
			enemy.position.y = -20.0
			enemy.rotation = PI
			spawn_timer = spawn_cooldown
			
	if Input.is_action_just_pressed("debug"):
		print($EnemyLayer.get_child_count())
		
	# process player fuel ui
	var player = get_tree().get_first_node_in_group("player")
	$Fuel.text = str(player.fuel)
	
	$Kills.text = str($EnemyLayer.kill_count)
	

func on_bounds_exited(area):
	area.queue_free()
