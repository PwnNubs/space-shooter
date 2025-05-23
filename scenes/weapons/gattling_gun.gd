extends Node2D

# Bullet
#@onready var bullet := load("res://scenes/projectiles/simple_bullet.tscn")
@export var bullet_scene: PackedScene
var shoot_cooldown := 0.01
var shoot_timer := shoot_cooldown
@onready var bullet_layer := get_tree().get_first_node_in_group("BulletLayer")

func _physics_process(delta: float) -> void:
	shoot_timer -= delta
	if shoot_timer > 0.0:
		return

	shoot_timer = shoot_cooldown
	var n_bullet := 1
	var spacing := 10.0
	for n in n_bullet:
		$ShootAudio.pitch_scale = randf_range(0.95, 1.05)
		$ShootAudio.play()
		var bullet = bullet_scene.instantiate()
		var grid_offset = ((n_bullet - 1) * (spacing / 2)) - (n * spacing)
		# setup rotation
		var angle := rotation
		bullet.rotation = angle
		# setup position
		bullet.position = global_position
		bullet.position.x -= grid_offset * cos(bullet.rotation)
		bullet.position.y -= grid_offset * sin(bullet.rotation)
		# removing the addition of player velocity for now
		bullet.velocity = (Vector2.from_angle(angle - (PI / 2) + randf_range(-0.2, 0.2)) * bullet.speed)# + (velocity / 8.0)
		bullet.damage = 0.2
		bullet.scale *= 0.8
		bullet_layer.add_child(bullet)
