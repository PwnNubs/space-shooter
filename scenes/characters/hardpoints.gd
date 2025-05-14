extends Node2D

class Hardpoint:
	var marker: Marker2D
	var occupied: bool
	var time_vacant := 0.0
	var time_occupied := 0.0
	
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
		else:
			n.time_occupied += delta

func check_full() -> bool:
	for n in slots:
		if not n.occupied:
			return false
	return true

func check_empty() -> bool:
	for n in slots:
		if n.occupied:
			return false
	return true

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
		if node.get_parent():
			node.get_praent().remove_child(node)
		longest_vacant_slot.marker.add_child(node)
		longest_vacant_slot.time_vacant = 0.0
		longest_vacant_slot.occupied = true
		return true
	else:
		return false # unable to fill any slots

func release_slot() -> Node2D:
	var longest_occupied_slot: Hardpoint = null
	for n in slots:
		if n.occupied:
			if longest_occupied_slot:
				if longest_occupied_slot.time_occupied < n.time_occupied:
					longest_occupied_slot = n
			else:
				longest_occupied_slot = n
	
	if longest_occupied_slot:
		var node: Node2D = longest_occupied_slot.marker.get_child(0)
		node.position = node.global_position
		longest_occupied_slot.marker.remove_child(node)
		longest_occupied_slot.time_occupied = 0.0
		longest_occupied_slot.occupied = false
		return node
	else:
		return null # unable to fill any slots
