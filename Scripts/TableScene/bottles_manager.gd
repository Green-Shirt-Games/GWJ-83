class_name BottlesOnTableManager
extends Control

@export var bottles_locations : Array[Marker2D]
var bottles_at_locations : Array[BottleOnTable]

func check_for_room_for_bottle() -> bool:
	return bottles_at_locations.size() > bottles_locations.size()

func add_bottle(bottle_data : BottleData) -> bool:
	if bottles_at_locations.size() > bottles_locations.size():
		var new_bottle = BottleOnTable.new(bottle_data)
		add_child(new_bottle)
		new_bottle.pressed.connect(new_bottle)
	else:
		return false
	return true # if there's place for bottle

func bottle_pressed(bottle : BottleOnTable) -> void:
	print(bottle.bottle_data.TYPE, " is pressed")
