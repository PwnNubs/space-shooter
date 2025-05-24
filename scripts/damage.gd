extends Node
class_name Damage

enum TYPE {
	PHYSICAL,
	ELECTRIC
}

@export var amount: float
@export var type: TYPE
