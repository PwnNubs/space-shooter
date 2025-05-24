extends Node2D

var shoot_cooldown := 0.2
var shoot_timer := shoot_cooldown
@export var damage: Damage
@onready var bullet_layer := get_tree().get_first_node_in_group("BulletLayer")
@export var lightning_bolt_scene: PackedScene

func _physics_process(delta: float) -> void:
	position.y -= 0.5
		
	shoot_timer -= delta
	if shoot_timer > 0.0:
		return

	shoot_timer = shoot_cooldown
	var lightning_bolt = lightning_bolt_scene.instantiate()
	lightning_bolt.global_position = global_position
	lightning_bolt.reach = 40.0
	lightning_bolt.reach_decay = 0.4
	lightning_bolt.max_chain = 5
	lightning_bolt.damage = damage.duplicate()
	lightning_bolt.damage_decay = 0.8
	bullet_layer.add_child(lightning_bolt)
	
