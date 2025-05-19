extends Area2D

@export var explosion_scene: PackedScene

var velocity := Vector2.ZERO
var speed := 80.0
var turn_limit := 0.02
var target : Vector2

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if (area.is_in_group("player")
	 or area.is_in_group("boundary")):
		return
	
	call_deferred("detonate")

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		queue_free()

func detonate():
	var explosion := explosion_scene.instantiate()
	explosion.radius = 80.0#24.0
	get_parent().add_child(explosion)
	explosion.trigger(global_position)
	queue_free()
