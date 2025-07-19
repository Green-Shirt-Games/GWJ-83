extends Node2D
class_name Door

signal on_door_opened
signal to_table_pressed
signal exit_pressed

@onready var to_table_button1 : Button = $Button
@onready var toggle_fullscreen_button : Button = $FullscreenToggle
@onready var exit_game : Button = $Exit

var door_open_count : int = 0

func _ready() -> void:
	to_table_button1.pressed.connect(
		func():
			to_table_pressed.emit()
	)
	
	toggle_fullscreen_button.pressed.connect(toggle_fullscreen)
	exit_game.pressed.connect(on_exit)
	
	door_open_count += 1
	get_tree().create_timer(3).timeout.connect(func(): on_door_opened.emit())


var is_fullscreen := true
func toggle_fullscreen():
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	is_fullscreen = !is_fullscreen


func on_exit():
	#chnage to thanks splash
	is_fullscreen = true
	exit_pressed.emit()
	toggle_fullscreen()
	get_tree().quit()
