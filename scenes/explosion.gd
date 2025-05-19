extends Node2D
class_name Explosion

#var force: float
@export var damage: float = 100.0
@export var radius: float = 40.0

@export var sprite_frames: SpriteFrames
@export var particles: GPUParticles2D

@onready var _damage_area := $Area2D
@onready var _animated_sprite := $AnimatedSprite2D

func _ready() -> void:
	# set defaults if not given

	if not particles:
		particles = $GPUParticles2D
	if not sprite_frames:
		sprite_frames = SpriteFrames.new()
	_animated_sprite.sprite_frames = sprite_frames
	_animated_sprite.hide()
	
	var shape = CircleShape2D.new()
	shape.radius = radius
	_damage_area.get_node("CollisionShape2D").shape = shape


func trigger(location: Vector2) -> void:
	global_position = location
	await get_tree().physics_frame
	
	_animated_sprite.show()
	_animated_sprite.play()
	particles.emitting = true
	for area in _damage_area.get_overlapping_areas():
		if "health" in area:
			area.damage(damage)
	await _animated_sprite.animation_finished
	
	queue_free()
