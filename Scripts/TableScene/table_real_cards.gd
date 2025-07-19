class_name CardsTable
extends Node2D

@export_group("Internal connections")
@export var dealers_hand : CardHand
@export var player_hands : Array[CardHand]
@export var shoe_marker : Marker2D
@export var discard_marker : Marker2D
@export var table_size : ColorRect

var shoe_card : CardVisual = null

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
	for hand in player_hands:
		hand._update_card_positions(null)

func _on_debug_pressed() -> void:
	dealers_hand._update_card_positions(null)
	for hand in player_hands:
		hand._update_card_positions(null)

func move_card_to_discard(card_to_move : CardVisual):
	card_to_move.reparent(self, true)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(card_to_move, "position", discard_marker.position, 0.2) # TODO attach to global fly timer
	await tween.finished

func move_card_to_shoe(card_to_move : CardVisual):
	card_to_move.reparent(self, true)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(card_to_move, "position", shoe_marker.position, 0.2) # TODO attach to global fly timer
	await tween.finished

func can_peek_shoe() -> bool:
	return shoe_card == null and Global.table.draw_deck.size() > 0

func peek_shoe():
	if shoe_card:
		return false
	#var shoe_card = CardVisual.new()
	shoe_card.card_data = Global.table.draw_deck[0].duplicate()
	add_child(shoe_card)
	shoe_card.position = shoe_marker.position
	await shoe_card.reveal()

func remove_peeked_shoe() -> void:
	if shoe_card:
		shoe_card.queue_free()
		shoe_card = null
