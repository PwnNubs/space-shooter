extends Area2D
class_name Explosion

#var force: float
@export var damage: Damage
@export var radius: float
@export var audio_stream: AudioStream

var particles: GPUParticles2D

func _ready() -> void:
	# get particles child
	if not particles:
		particles = $GPUParticles2D
	# huh, me, nothing
	set_process(false)
	hide()


func trigger() -> void:
	await get_tree().physics_frame
	
	reparent(get_tree().get_nodes_in_group("ExplosionLayer")[0])
	set_process(true)
	show()

	var animations: Array[AnimatedSprite2D]
	for child in get_children():
		if child is AnimatedSprite2D:
			animations.append(child)
			
	for animation in animations:
		animation.play()
	
	particles.emitting = true
	
	if audio_stream:
		var explosion_layer = get_tree().get_first_node_in_group("ExplosionLayer")
		explosion_layer.request_play_audio(audio_stream)
	
	# if radius and has a shape, set shape size
	# if radius no shape, setup a shape
	# if no radius and shape, do nothing
	# if no radius and no shape, printerr()
	#
	var collision_shapes: Array[CollisionShape2D] #= find_children("*", "CollisionShape2D")
	for shape in get_children():
		if shape is CollisionShape2D:
			collision_shapes.append(shape)
			
	if radius > 0.01 and collision_shapes.size() > 0:
		collision_shapes[0].shape.radius = radius
	elif radius > 0.01 and collision_shapes.size() == 0:
		var shape = CircleShape2D.new()
		shape.radius = radius
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = shape
		add_child(collision_shape)
		collision_shapes.append(collision_shape)
	elif radius == 0.0 and collision_shapes.size() == 0:
		printerr("Explosion: ", self, "needs a radius or CollisionShape2D child to work")
		queue_free()
	
	# double the radius so they are captured in falloff calculation
	#print(collision_shapes.size())
	for cs in collision_shapes:
		var shape = CircleShape2D.new()
		shape.radius = cs.shape.radius * 2
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = shape
		add_child(collision_shape)
	
		
	await get_tree().physics_frame
	await get_tree().physics_frame
	for body in get_overlapping_bodies():#get_overlapping_areas():
		if "health" in body:
			var distance = global_position.distance_to(body.global_position)
			if distance <= collision_shapes[0].shape.radius:
				body.hit(damage)
			else:
				var a_damage = damage
				a_damage.amount *= (collision_shapes[0].shape.radius / distance) * (collision_shapes[0].shape.radius / distance)
				body.hit(a_damage)

	for animation in animations:
		await animation.animation_finished
	
	queue_free()
