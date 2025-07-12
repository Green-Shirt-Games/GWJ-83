extends Node2D


@onready var bar : Bar = $Bar
@onready var table : Table = $Table
@onready var door : Door = $Door


func _ready() -> void:
	table.visible = true
	bar.visible = false
	door.visible = false
	
	bar.to_table_pressed.connect(_on_bar_to_table)
	table.to_bar_pressed.connect(_on_table_to_bar)
	table.to_exit_pressed.connect(_on_table_to_exit)
	door.to_table_pressed.connect(_on_exit_to_table)


func _on_table_to_bar():
	table.visible = false
	bar.visible = true


func _on_exit_to_table():
	table.visible = true
	door.visible = false


func _on_table_to_exit():
	table.visible = false
	door.visible = true


func _on_bar_to_table():
	table.visible = true
	bar.visible = false
