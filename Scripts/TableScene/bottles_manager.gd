class_name BottlesOnTableManager
extends Control

@export var bottles_locations : Array[Marker2D]
var bottles_at_locations : Array[BottleOnTable]

func check_for_room_for_bottle(amount : int) -> bool:
	return bottles_locations.size() + amount >= bottles_locations.size()

func add_bottle(bottle_data : BottleData) -> void:
	if !check_for_room_for_bottle(1):
		push_error("Trying to fit bottle that doesn't fit on table")
		return
	var new_bottle = BottleOnTable.new(bottle_data)
	add_child(new_bottle)
	bottles_at_locations.append(new_bottle)
	new_bottle.pressed.connect(new_bottle)
	

func bottle_pressed(bottle : BottleOnTable) -> void:
	print(bottle.bottle_data.TYPE, " is pressed")
