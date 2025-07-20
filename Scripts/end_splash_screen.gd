extends Control

@export var game_result_label : Label
@export var exit_button : Button

func _ready() -> void:
	if OS.has_feature("web"):
		exit_button.visible = false
	update_win_lose_label() # Pass bool that player won / lost


func update_win_lose_label(player_won : bool = false) -> void:
	if player_won:
		game_result_label.text = "Congratulations!"
	else:
		game_result_label.text = "Game over"


func _on_exit_pressed() -> void:
	get_tree().quit()
