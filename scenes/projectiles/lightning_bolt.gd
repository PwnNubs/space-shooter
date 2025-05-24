extends Area2D

var chain: int
var max_chain: int
var reach_decay := 0.5
@export var reach: float
@export var damage: Damage
var damage_decay: float
var lightning_layer: Node2D
var line := Line2D.new()
var origin: Node2D
var shocked: Array[Node2D]

var lifetime := 0.4
var lifetime_timer := lifetime


# !To Do! #
# do incrementally larger collison detections
# starting size based on number of enemies on enemy layer
func _ready() -> void:
	if not lightning_layer:
		lightning_layer = get_tree().get_first_node_in_group("BulletLayer")
	
	$CollisionShape2D.shape.radius = reach
	await get_tree().physics_frame
	var body_list := get_overlapping_bodies()
	if body_list.is_empty():
		return
	
	# nearest may still be null after
	var nearest_body: Node2D = null
	var nearest_distance := INF
	for body in get_overlapping_bodies():
		var test_distance := global_position.distance_to(body.global_position)
		if (test_distance < nearest_distance
		  and shocked.find(body) == -1
		  and body.disabled_timer <= 0.0):
			nearest_body = body
			nearest_distance = test_distance
	
	if not nearest_body:
		return
		
	shocked.append(nearest_body)
	nearest_body.hit(damage)
	
	line.add_point(global_position)
	line.add_point(nearest_body.global_position)
	line.width = 1
	line.antialiased = true
	add_sibling(line)
	
		## spawn next
	if chain < max_chain:
		var next_bolt := duplicate()
		next_bolt.global_position = nearest_body.global_position
		next_bolt.chain = chain + 1
		next_bolt.max_chain = max_chain
		next_bolt.reach = reach * reach_decay
		next_bolt.damage.amount = damage.amount * damage_decay
		next_bolt.origin = nearest_body
		next_bolt.shocked = shocked
		add_sibling(next_bolt)


func _process(delta: float) -> void:
	lifetime_timer -= delta
	if lifetime_timer <= 0.0:
		line.queue_free()
		queue_free()
