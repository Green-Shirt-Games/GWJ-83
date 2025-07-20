extends TextureButton

@export var room_to_change_to : Global.ROOMS

func _ready() -> void:
	mouse_entered.connect(SfxAutoload.on_button_hover)
	pressed.connect(SfxAutoload.on_button_pressed)


func _pressed() -> void:
	Global.change_room.emit(room_to_change_to)
	SfxAutoload.player_rotate()
