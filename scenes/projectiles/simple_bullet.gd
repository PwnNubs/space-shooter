extends Area2D

var velocity := Vector2.ZERO
var speed := 140.0
var lifetime := 240.0 / speed

func _process(delta):
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player"):
		if area.is_in_group("enemy"):
			area.health -= 5.0
		queue_free()
