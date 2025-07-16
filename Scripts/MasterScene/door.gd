extends Node2D
class_name Door

signal to_table_pressed

@onready var to_table_button1 : Button = $Button
@onready var to_table_button2 : Button = $Button2

func _ready() -> void:
	to_table_button1.pressed.connect(
		func():
			to_table_pressed.emit()
	)
