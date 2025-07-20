extends Sprite2D


@onready var door_area : Area2D = $Area2D
@onready var locked_audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
var locked : bool = true
var door_open_count : int = 0

func _ready() -> void:
	door_area.mouse_entered.connect(_on_mouse_enter)
	door_area.mouse_exited.connect(_on_mouse_exit)
	door_area.input_event.connect(_input_event)
	Global.key_purchased.connect(_unlock)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_select()


func _on_select():
	if locked:
		locked_audio.play()
	else:
		door_open_count += 1
		Global.player_exited_door.emit(door_open_count)


func _unlock():
	locked = false


func _on_mouse_enter():
	pass


func _on_mouse_exit():
	pass
