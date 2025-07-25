extends Node2D
class_name Door

signal exit_pressed

@onready var exit_game : TextureButtonWithSFX = $Exit



func _ready() -> void:	
	exit_game.pressed.connect(on_exit)


var is_fullscreen := false
func toggle_fullscreen():
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	is_fullscreen = !is_fullscreen


func on_exit():
	#chnage to thanks splash
	if OS.has_feature("web"):
		return
	is_fullscreen = true
	exit_pressed.emit()
	toggle_fullscreen()
	get_tree().quit()
