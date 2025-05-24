extends Area2D

var velocity := Vector2.ZERO
var speed := 140.0

@export var damage: Damage

func _process(delta: float) -> void:
	position += velocity * delta

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.hit(damage)
	
	$BulletHitAudio.pitch_scale = randf_range(0.95, 1.05)
	$BulletHitAudio.play()
	$CollisionShape2D.queue_free()
	hide()
	await $BulletHitAudio.finished
	queue_free()
