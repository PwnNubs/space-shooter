extends Node2D

var shoot_cooldown := 4.0
var shoot_timer := shoot_cooldown
@onready var bullet_layer := get_tree().get_first_node_in_group("BulletLayer")
@export var spark_orb_scene: PackedScene

func _physics_process(delta: float) -> void:
	shoot_timer -= delta
	if shoot_timer > 0.0:
		return

	shoot_timer = shoot_cooldown
	var spark_orb := spark_orb_scene.instantiate()
	spark_orb.global_position = global_position
	bullet_layer.add_child(spark_orb)
