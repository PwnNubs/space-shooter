extends Area2D

var velocity := Vector2.ZERO
var speed := 80.0
var turn_limit := 0.02
var target : Vector2

func _physics_process(delta: float) -> void:
	position += velocity * delta

#func _on_area_entered(area: Area2D) -> void:
	#if (area.is_in_group("player")
	 #or area.is_in_group("boundary")):
		#return
	#
	#call_deferred("detonate")

func _on_body_entered(_body: Node2D) -> void:
	detonate()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		queue_free()

func detonate() -> void:
	$Explosion.trigger()
	# must wait because can be triggered by player input
	await get_tree().physics_frame
	queue_free()
