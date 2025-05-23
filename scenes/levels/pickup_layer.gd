extends Node2D

@export var pickup_scene: PackedScene

var orb_values := [64.0, 32.0, 16.0, 8.0, 4.0, 2.0]

func spawn(amount: float, pos: Vector2) -> void:
	await get_tree().physics_frame
	
	# almost. needs to have ability to spawn partial final one
	for value in orb_values:
		var orb_count = floorf(amount / value)
		amount -= orb_count * value
		for n in orb_count:
			var pickup = pickup_scene.instantiate()
			pickup.value = value
			pickup.scale *= sqrt(value)
			pos += Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
			pickup.position = pos
			add_child(pickup)
	
	# spawn remainder
	if amount > 0.0:
		var pickup = pickup_scene.instantiate()
		pickup.value = amount
		pickup.scale *= sqrt(orb_values.back())
		pos += Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
		pickup.position = pos
		add_child(pickup)
