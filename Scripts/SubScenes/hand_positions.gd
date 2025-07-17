extends Node2D
class_name HandPositions

@onready var base_position : Marker2D = $card1Pos
@onready var offset : Marker2D = $CardOffset

## Get global position of card index
func get_pos(index : int) -> Vector2:
	var offset : Vector2 = offset.global_position - base_position.global_position
	return base_position.global_position + offset*index
