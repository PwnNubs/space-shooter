extends Node2D

class Hardpoint:
	var marker: Marker2D
	var occupied: bool
	var time_vacant := 0.0
	
	func _init(_marker: Marker2D, _occupied: bool):
		marker = _marker
		occupied = _occupied

var slots: Array[Hardpoint]

func _ready():
	for n in get_children():
		slots.push_back(Hardpoint.new(n, false))

func _process(delta: float) -> void:
	for n in slots:
		if not n.occupied:
			n.time_vacant += delta

func fill_slot(node: Node2D) -> bool:
	var longest_vacant_slot: Hardpoint = null
	for n in slots:
		if not n.occupied:
			if longest_vacant_slot:
				if longest_vacant_slot.time_vacant < n.time_vacant:
					longest_vacant_slot = n
			else:
				longest_vacant_slot = n
	
	if longest_vacant_slot:
		remove_child(node)
		longest_vacant_slot.marker.add_child(node)
		longest_vacant_slot.time_vacant = 0.0
		return true
	else:
		return false # unable to fill any slots

func release_slot() -> Node2D:
	return Node2D.new()
