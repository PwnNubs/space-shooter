extends Node2D
class_name Explosion

#var force: float
var damage: float = 100.0
var radius: float = 40.0

@onready var animated_spride := $AnimatedSprite2D
@onready var damage_area := $Area2D

func _ready() -> void:
	var shape = CircleShape2D.new()
	shape.radius = radius
	damage_area.get_node("CollisionShape2D").shape = shape

func trigger(location: Vector2) -> void:
	global_position = location
	await get_tree().physics_frame
	for area in damage_area.get_overlapping_areas():
		if "health" in area:
			area.damage(damage)
	queue_free()
