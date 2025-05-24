extends Node2D

const simple_enemy_res = preload("res://resources/enemies/simple_enemy.tres")
var a_enemy := preload("res://scenes/characters/enemy.tscn")
var spawn_cooldown: float = 0.06#1.5 0.05
var spawn_timer: float = spawn_cooldown
@onready var screen_size = get_viewport_rect().size

func _ready():
	#get_tree().debug_collisions_hint = true
	pass

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
		print("--- Node Count ---")
		print("EnemyLayer:", $EnemyLayer.get_child_count())
		print("BulletLayer:", $BulletLayer.get_child_count())
		print("PickupLayer:", $PickupLayer.get_child_count())
	
	var bounds := [-180.0, 540.0, -232.0, 696.0]
	for i in get_child_count():
		var child = get_child(i)
		if (child.position.x < bounds[0] or child.position.x > bounds[1]
		  or child.position.y < bounds[2] or child.position.y > bounds[3]):
			child.queue_free()
			print("wacked") 
	# process player fuel ui
	var player = get_tree().get_first_node_in_group("player")
	#$Fuel.text = str(roundf($Player.fuel * 10.0) / 10.0)
	$Fuel.size.x = player.fuel * (64.0 / player.fuel_max)
	$Points.text = str(player.points)
	#$Kills.text = str($EnemyLayer.kill_count)
	
func _on_killzone_entered(node) -> void:
	node.queue_free()
