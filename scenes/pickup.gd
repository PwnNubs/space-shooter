extends Area2D

@export var value: float
var _target_area: Area2D

func _physics_process(_delta: float) -> void:
	if _target_area and _target_area.type == 0:
		position -= (global_position - _target_area.global_position) / 20.0
	else:
		position.y += 0.8

func _on_area_entered(area: Area2D) -> void:
	match area.type:
		0:
			_target_area = area
		1:
			area.owner.points += value
			queue_free()
	
func _on_area_exited(area: Area2D) -> void:
	match area.type:
		0:
			_target_area = null
