extends Control


@onready var bar := $Bar
@onready var table := $TableScene
@onready var door := $Door


var current_room : Global.ROOMS = Global.ROOMS.DOOR

func _ready() -> void:
	Global.change_room.connect(_change_room)
	_change_room(Global.ROOMS.TABLE)

func _change_room(to : Global.ROOMS) -> void:
	if to == current_room:
		push_error("Trying to change into same room")
		return
	match current_room:
		Global.ROOMS.BAR:
			bar.visible = false
			set_physics_process(false)
		Global.ROOMS.TABLE:
			table.visible = false
		Global.ROOMS.DOOR:
			door.visible = false
	match to:
		Global.ROOMS.BAR:
			bar.visible = true
			set_physics_process(true)
		Global.ROOMS.TABLE:
			table.visible = true
		Global.ROOMS.DOOR:
			door.visible = true
	current_room = to
