extends Control

@export var game_result_label : Label
@export var exit_button : Label

func _ready() -> void:
	exit_button.visible = OS.has_feature("windows") or OS.has_feature("ios")


func update_win_lose_label(player_won : bool = false) -> void:
	if player_won:
		game_result_label.text = "Congratulations!"
	else:
		game_result_label.text = "Game over"


func _on_exit_pressed() -> void:
	get_tree().quit()
