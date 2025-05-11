extends Area2D

var velocity := Vector2.ZERO
var speed := 100.0
var lifetime := 240.0 / speed

func _process(delta):
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
