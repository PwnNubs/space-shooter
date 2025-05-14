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

# system for autorefill
var autorefill := true
var cooldown := 1.0

signal request_refill(index: int)

func _ready():
	for n in get_children():
		slots.push_back(Hardpoint.new(n, false))

func _process(delta: float) -> void:
	for n in slots:
		if not n.occupied:
			n.time_vacant += delta
		else:
			n.time_occupied += delta
	
	if autorefill:
		for i in slots.size():
			if slots[i].time_vacant >= cooldown:
				request_refill.emit(i)

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

func fill_slot(node: Node2D, slot: int) -> bool:
	if slots[slot]:
		if node.get_parent():
			node.get_praent().remove_child(node)
		slots[slot].marker.add_child(node)
		slots[slot].time_vacant = 0.0
		slots[slot].occupied = true
		return true
	else:
		return false # unable to fill any slots

# return false if no empty slots
# otherwise fill longest vacant slot
func fill_a_slot(node: Node2D) -> bool:
	# return if no empty slots
	if check_full():
		return false
		
	var lv_i := 0	# longest vacant slot index
	for i in slots.size():
		if slots[lv_i].time_vacant < slots[i].time_vacant:
			lv_i = i
	
	return fill_slot(node, lv_i)

func release_slot(slot: int) -> Node2D:
	if slots[slot]:
		var node: Node2D = slots[slot].marker.get_child(0)
		node.position = node.global_position
		slots[slot].marker.remove_child(node)
		slots[slot].time_occupied = 0.0
		slots[slot].occupied = false
		return node
	else:
		return null # unable to fill any slots

# return null if empty
# otherwise release longest occupied slot
func release_a_slot() -> Node2D:
	# return if empty
	if check_empty():
		return null
		
	var lo_i := 0	# longest occupied slot index
	for i in slots.size():
		if slots[lo_i].time_occupied < slots[i].time_occupied:
			lo_i = i
	
	return release_slot(lo_i)
