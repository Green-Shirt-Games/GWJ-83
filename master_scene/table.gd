extends Node2D
class_name Table

signal to_exit_pressed
signal to_bar_pressed


@onready var to_exit_button : Button = $ExitButton
@onready var to_bar_button : Button = $BarButton


func _ready() -> void:
	to_bar_button.pressed.connect(
		func():
			to_bar_pressed.emit()
	)
	
	to_exit_button.pressed.connect(
		func():
			to_exit_pressed.emit()
	)
