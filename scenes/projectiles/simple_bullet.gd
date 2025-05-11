extends Area2D

var velocity := Vector2.ZERO
var speed := 10.0

func _process(delta):
	position += velocity * speed * delta
	
func _on_area_entered(area: Area2D) -> void:
	pass #print(area)
