extends Area2D

var velocity := Vector2.ZERO
var speed := 80.0
var turn_limit := 0.4

func _process(delta: float) -> void:
	position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player") && not area.is_in_group("boundary"):
		if area.is_in_group("enemy"):
			area.damage(20.0)
		queue_free()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		queue_free()

func detonate():
	print("boom")
	queue_free()
