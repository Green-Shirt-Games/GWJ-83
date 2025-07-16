extends Node2D

@export var dealers_hand : CardHand
@export var player_hands : Array[CardHand]
@export var table_size : ColorRect

func _ready() -> void:
	adjust_hands_positions()

func adjust_hands_positions() -> void:
	dealers_hand.position.y = Global.CARD_TEXTURE_SIZE.y / 2.0
	dealers_hand.default_y_position = Global.CARD_TEXTURE_SIZE.y / 2.0
	dealers_hand.table_size_x = table_size.get_rect().size.x
	for i in player_hands:
		i.position.y = table_size.get_rect().size.y - Global.CARD_TEXTURE_SIZE.y / 2.0
		i.default_y_position = table_size.get_rect().size.y - Global.CARD_TEXTURE_SIZE.y / 2.0
	player_hands[0].table_size_x = table_size.get_rect().size.x
	player_hands[1].table_size_x = table_size.get_rect().size.x / 2.0
	player_hands[1].position.x = table_size.get_rect().size.x / 2.0
	player_hands[1].default_x_position = table_size.get_rect().size.x / 2.0

func second_players_hand(activate : bool) -> void:
	if activate:
		player_hands[0].table_size_x = table_size.get_rect().size.x / 2.0
		player_hands[0].offset_direction = -1
	else:
		player_hands[0].table_size_x = table_size.get_rect().size.x
		player_hands[0].offset_direction = 1

func _on_debug_pressed() -> void:
	dealers_hand._update_card_positions(null)
	for hand in player_hands:
		hand._update_card_positions(null)
