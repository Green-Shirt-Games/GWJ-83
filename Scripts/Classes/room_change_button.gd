## Button intended to be used to change between rooms

class_name RoomChangeButton
extends ButtonWithSFX

@export var room_to_change_to : Global.ROOMS

func _pressed() -> void:
	Global.change_room.emit(room_to_change_to)
