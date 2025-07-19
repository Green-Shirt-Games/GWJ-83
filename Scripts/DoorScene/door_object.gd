extends Sprite2D


@onready var door_area : Area2D = $Area2D
@onready var locked_audio : AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	door_area.mouse_entered.connect(_on_mouse_enter)
	door_area.mouse_exited.connect(_on_mouse_exit)

func _input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		_on_select()


func _on_select():
	locked_audio.play()


func _on_mouse_enter():
	pass


func _on_mouse_exit():
	pass
