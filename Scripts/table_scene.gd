class_name TableScene
extends Control

@export_group("Internal connections")
@export var bet_manager : BetManager
@export var bottles_manager : BottlesOnTableManager
@export_subgroup("UI elements")
@export var cards_table : CardsTable
@export var play_buttons_container : Control
@export var split_button : Button
@export var double_down_button : Button
@export var player_money_label : Label
@export var change_room_buttons : Array[RoomChangeButton]
@export var bet_visual_managers_multiple_hands : Array[BetVisualManager]
@export var bet_visual_manager_single_hand : BetVisualManager
@export var place_for_chips_to_fly_away : Marker2D


# temp code, to be moved to separate GamaManager, to keep data about table between scene changes

var player_hands : Array[CardHand]
var dealer_hand : CardHand

var active_player_hand : int = 0
var current_state : Global.GAME_STATES 
var draw_deck : Array[CardData] = []
var discard_deck : Array[CardData] = []
var hands_played : int = 0
var bet : int = 0 :
	set(new_value):
		if bet != new_value:
			bet = new_value
			bet_changed()
var second_hand_bet : int = 0 :
	set(new_value):
		if second_hand_bet != new_value:
			second_hand_bet = new_value
			bet_changed()
		
signal state_changed(to_stage)

var default_card_fly_time : float = 0.3
var default_timer_timeout : float = 0.3
var skip_dealing : bool = false

func _ready() -> void:
	Global.table = self
	player_hands = cards_table.player_hands
	dealer_hand = cards_table.dealers_hand
	player_hands[1].is_active = false
	Global.money_changed.connect(_update_money_label)
	visibility_changed.connect(update_bet_manager)
	state_changed.connect(bottles_manager.disable_bottles_if_needed)
	_game_start()
	_change_state(Global.GAME_STATES.INTRO)
	_update_money_label()

func _change_state(new_state : Global.GAME_STATES) -> void:
	current_state = new_state
	state_changed.emit(new_state)
	match current_state:
		Global.GAME_STATES.INTRO:
			play_buttons_container.visible = false
			bet_manager.visible = false
			#await animation and dialog finished
			toggle_other_room_buttons_visible(false)
			_change_state(Global.GAME_STATES.BETTING)
		Global.GAME_STATES.BETTING:
			
			play_buttons_container.visible = false
			bet_manager.visible = true
		Global.GAME_STATES.DEALING:
			if skip_dealing:
				skip_dealing = false
			else:
				bet_manager.visible = false
				play_buttons_container.visible = false
				while player_hands[0].get_cards_amount() < 2:
					#await _give_player_two_same_cards()
					await _add_card_to_player_hand()
				if dealer_hand.get_cards_amount() < 1:
					await _add_card_to_dealer_hand(true)
				if dealer_hand.get_cards_amount() < 2:
					await _add_card_to_dealer_hand(false)
			_change_state(Global.GAME_STATES.PLAYER_TURN)
		Global.GAME_STATES.PLAYER_TURN:
			play_buttons_container.visible = true
			bet_manager.visible = false
			split_button.visible = _check_if_split_possible()
		Global.GAME_STATES.DEALER_TURN:
			play_buttons_container.visible = false
			bet_manager.visible = false
			for hand in player_hands:
				for card in hand.get_children():
					await (card as CardVisual).reveal()
			
			var player_full_bust : bool = true
			for hand in player_hands:
				if hand.is_active and not hand.bust:
					player_full_bust = false
			if player_full_bust:
				_change_state(Global.GAME_STATES.RESULT)
			
			for card in dealer_hand.get_children():
				await (card as CardVisual).reveal()
			while dealer_hand.best_score < 17:
				await _add_card_to_dealer_hand(true)
			_change_state(Global.GAME_STATES.RESULT)
		Global.GAME_STATES.RESULT:
			play_buttons_container.visible = false
			bet_manager.visible = false
			for i in player_hands.size():
				var hand = player_hands[i]
				if hand.is_active:
					if dealer_hand.bust:
						if hand.bust:
							await _player_tied(i)
						else:
							await _player_won(i)
					else:
						if hand.bust:
							await _player_lost(i)
						else:
							if hand.best_score > dealer_hand.best_score:
								await _player_won(i)
							elif hand.best_score < dealer_hand.best_score:
								await _player_lost(i)
							else:
								await _player_tied(i)
			await get_tree().create_timer(2).timeout #TODO move this await to voiceline trigger
			_change_state(Global.GAME_STATES.RESET)
		Global.GAME_STATES.RESET:
			play_buttons_container.visible = false
			bet_manager.visible = false
			for card in dealer_hand.get_children():
				if !(card as CardVisual).is_frozen:
					move_card_to_discard(card)
			dealer_hand.reset()
			for hand in player_hands:
				for card in hand.get_children():
					if !(card as CardVisual).is_frozen:
						move_card_to_discard(card)
				(hand as CardHand).reset()
			if player_hands[1].is_active:
				for card in player_hands[1].get_children():
					move_card_to_hand(card, player_hands[0])
			player_hands[1].is_active = false
			active_player_hand = 0
			cards_table.second_players_hand(false)
			# reset deck, if cards left is less than 15 (overkill?)
			if draw_deck.size() < 15:
				_reset_deck()
			# wait for animation to finish
			hands_played += 1
			await get_tree().create_timer(default_timer_timeout).timeout # TODO Connect to all card fly speed
			print("new game")
			_change_state(Global.GAME_STATES.BETTING)

func _check_if_split_possible() -> bool:
	return (player_hands[0].get_child(0) as CardVisual).card_data.value == \
			(player_hands[0].get_child(1) as CardVisual).card_data.value and \
			Global.money >= bet

func _game_start() -> void:
	_prepare_deck()
	_reset_deck()

func _prepare_deck() -> void:
	for suit in Global.CARD_SUITS.size():
		for value in Global.CARD_VALUES.size():
			draw_deck.append(
				CardData.new(
					value as Global.CARD_VALUES,
					suit as Global.CARD_SUITS
					)
				)

func _reset_deck() -> void:
	draw_deck.append_array(discard_deck)
	discard_deck.clear()
	draw_deck.shuffle()

#region CardDraw
func _add_card_to_player_hand():
	var hand : CardHand = player_hands[active_player_hand]
	await move_card_to_hand(_draw_card(), hand)
	if hand.bust:
		if active_player_hand == 0 and player_hands[1].is_active:
			active_player_hand = 1
		else:
			_change_state(Global.GAME_STATES.RESULT)

func _give_player_two_same_cards(): # DebugTool
	var hand : CardHand = player_hands[active_player_hand]
	var card = _draw_card()
	var card_two = _draw_card()
	card_two.card_data = card.card_data
	card_two.update_visual()
	move_card_to_hand(card, hand)
	move_card_to_hand(card_two, hand)

func _add_card_to_dealer_hand(face_up : bool) -> void:
	var new_card : CardVisual = _draw_card()
	new_card.face_up = face_up
	new_card.update_visual()
	await move_card_to_hand(new_card, dealer_hand)

func _draw_card() -> CardVisual:
	var card : CardVisual = (load(Global.SUBSCENE_PATHS.card_visual) as PackedScene).instantiate()
	card.get_data(draw_deck.pop_front())
	cards_table.add_child(card)
	card.position = cards_table.shoe_marker.position
	return card
#endregion

func move_card_to_hand(card_to_move : CardVisual, to_hand : CardHand):
	if card_to_move.get_parent() != to_hand:
		card_to_move.reparent(to_hand, true)
	await to_hand.all_cards_in_position

func move_card_to_shoe(card_to_move : CardVisual):
	await cards_table.move_card_to_shoe(card_to_move)
	draw_deck.insert(0, card_to_move.card_data)
	card_to_move.queue_free()

func move_card_to_discard(card_to_move : CardVisual):
	card_to_move.flip(false)
	await cards_table.move_card_to_discard(card_to_move)
	discard_deck.append(card_to_move.card_data)
	card_to_move.queue_free()

#region Game results

func _player_won(hand_id : int):
	print("Player won with hand " , hand_id)
	match hand_id:
		0:
			if player_hands[1].is_active:
				if player_hands[hand_id].best_score == Global.POINTS_LIMIT:
					bet_visual_managers_multiple_hands[hand_id].update_bet(bet * 3)
				else:
					bet_visual_managers_multiple_hands[hand_id].update_bet(bet * 2)
				await get_tree().create_timer(0.3).timeout
				await move_chips_towards_player(bet_visual_managers_multiple_hands[hand_id])
			else:
				if player_hands[hand_id].best_score == Global.POINTS_LIMIT: # BlackJack
					bet_visual_manager_single_hand.update_bet(bet * 3)
				else:
					bet_visual_manager_single_hand.update_bet(bet * 2)
				await get_tree().create_timer(default_timer_timeout).timeout
				await move_chips_towards_player(bet_visual_manager_single_hand)
			if player_hands[hand_id].best_score == Global.POINTS_LIMIT: # BlackJack
				Global.money += bet * 3
			else:
				Global.money += bet * 2
		1:
			if player_hands[hand_id].best_score == Global.POINTS_LIMIT:
				bet_visual_managers_multiple_hands[1].update_bet(bet * 3)
			else:
				bet_visual_managers_multiple_hands[1].update_bet(bet * 2)
			await get_tree().create_timer(default_timer_timeout).timeout
			await move_chips_towards_player(bet_visual_managers_multiple_hands[hand_id])
			if player_hands[hand_id].best_score == Global.POINTS_LIMIT:
				Global.money += second_hand_bet * 3
			else:
				Global.money += second_hand_bet * 2
		

func move_chips_towards_player(bet_manager_of_those_chips : BetVisualManager):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(bet_manager_of_those_chips, "position", place_for_chips_to_fly_away.position, 0.3)
	await tween.finished
	bet_manager_of_those_chips.update_bet(0)
	bet_manager_of_those_chips.reset_position()

func _player_lost(_hand_id : int):
	toggle_other_room_buttons_visible(true)
	# chips fire animation goes here
	match _hand_id:
		0:
			if player_hands[1].is_active:
				bet_visual_managers_multiple_hands[0].update_bet(0)
			else:
				bet_visual_manager_single_hand.update_bet(0)
		1:
			bet_visual_managers_multiple_hands[1].update_bet(0)
		

func _player_tied(hand_id : int):
	match hand_id:
		0:
			Global.money += bet
			if player_hands[1].is_active:
				await move_chips_towards_player(bet_visual_managers_multiple_hands[0])
			else:
				await move_chips_towards_player(bet_visual_manager_single_hand)
		1:
			await move_chips_towards_player(bet_visual_managers_multiple_hands[1])
			Global.money += second_hand_bet
#endregion

func _update_money_label() -> void:
	player_money_label.text = "money: " + str(Global.money)

#region UI buttons
func _on_draw_cards_button_pressed() -> void:
	_change_state(Global.GAME_STATES.DEALING)

func _on_hit_button_pressed() -> void:
	_add_card_to_player_hand()

func _on_split_button_pressed() -> void:
	if Global.money >= bet:
		Global.money -= bet
		second_hand_bet = bet
		player_hands[1].is_active = true
		cards_table.second_players_hand(true)
		player_hands[0].get_child(1).reparent(player_hands[1], true)
		active_player_hand = 1
		_add_card_to_player_hand()
		active_player_hand = 0
		_add_card_to_player_hand()
		bet_visual_manager_single_hand.update_bet(0)
		bet_visual_managers_multiple_hands[0].update_bet(bet)
		bet_visual_managers_multiple_hands[1].update_bet(second_hand_bet)
	else:
		Global.not_enough_money.emit()

func _on_stand_button_pressed() -> void:
	if active_player_hand == 0 and player_hands[1].is_active:
		active_player_hand = 1
	else:
		_change_state(Global.GAME_STATES.DEALER_TURN)

func _on_double_down_button_pressed() -> void:
	if _double_bet():
		await _add_card_to_player_hand()
		if player_hands[active_player_hand].bust:
			if active_player_hand == 0 and player_hands[1].is_active:
				active_player_hand = 1
			else:
				_change_state(Global.GAME_STATES.RESULT)
		else:
			if active_player_hand == 0 and player_hands[1].is_active:
				active_player_hand = 1
			else:
				_change_state(Global.GAME_STATES.DEALER_TURN)
	else:
		Global.not_enough_money.emit()

#endregion

func _double_bet() -> bool:
	if Global.money >= bet:
		Global.money -= bet
		if active_player_hand == 0:
			bet *= 2
		else:
			second_hand_bet *= 2
		return true
	else:
		return false

func update_bet_manager() -> void:
	bet_manager._prepare_for_bets()

# Bottle Effect handling
func bottle_pressed(bottle_type : BottleData.TYPE) -> bool: 
	match bottle_type:
		BottleData.TYPE.PEEK_DEALER:
			if dealer_hand.get_cards_amount() > 0:
				for card in dealer_hand:
					if card is CardVisual:
						card.reveal()
			else:
				return false
		BottleData.TYPE.PEEK_SHOE:
			pass # TODO
			# Plan:
			# create a copy of top shoe card, flip it. On draw - q_free that card
		BottleData.TYPE.SWAP_DEALER:
			pass
			# pick random card in both active hands
			if player_hands[active_player_hand].get_cards_amount() > 0 and dealer_hand.get_cards_amount() > 0:
				var player_card_to_swap : CardVisual = player_hands[active_player_hand].get_children().pick_random()
				var dealer_card_to_swap : CardVisual = dealer_hand.get_children().pick_random()
				move_card_to_hand(player_card_to_swap, dealer_hand)
				await move_card_to_hand(dealer_card_to_swap, player_hands[active_player_hand])
			else:
				return false
		BottleData.TYPE.SPILL:
			pass # TODO
		BottleData.TYPE.SHOE_SWAP:
			if player_hands[active_player_hand].get_child_count() > 0:
				_add_card_to_player_hand()
				await move_card_to_shoe(player_hands[active_player_hand].get_children().pick_random())
			else:
				return false
		BottleData.TYPE.ROTATE:
			if player_hands[1].is_active:
				if player_hands[0].get_child_count() > 0 and player_hands[1].get_child_count() > 0 and dealer_hand.get_child_count() > 0:
					var player_card_0 = player_hands[0].get_children().front()
					var player_card_1 = player_hands[1].get_children().back()
					var dealer_card = dealer_hand.get_children().front()
					
					dealer_card.reparent(cards_table)
					player_card_1.reparent(dealer_hand)
					player_card_0.reparent(player_hands[1])
					player_hands[1].move_child(player_card_0, 0)
					dealer_card.reparent(player_hands[0])
				else:
					return false
			else:
				if player_hands[0].get_child_count() > 0 and dealer_hand.get_child_count() > 0:
					var player_card = player_hands[0].get_children().back()
					var dealers_card = dealer_hand.get_children().front() # Correct
					
					dealers_card.reparent(cards_table)
					player_card.reparent(dealer_hand)
					dealers_card.reparent(player_hands[0]) # Correct
					player_hands[0].move_child(dealers_card, 0)
				else:
					return false
			player_hands[0]._update_card_positions(null)
			player_hands[1]._update_card_positions(null)
			dealer_hand._update_card_positions(null)
		#BottleData.TYPE.SNEAK_BET:
			#skip_dealing = true
			#_change_state(Global.GAME_STATES.BETTING)
		BottleData.TYPE.DOUBLE:
			if !_double_bet():
				return false
		_:
			push_error("Unexpected bottle type triggered")
			return false
	return true

func toggle_other_room_buttons_visible(to : bool) -> void:
	for button in change_room_buttons:
		button.visible = to


func _on_debug_dupe_top_card_pressed() -> void:
	draw_deck.insert(0, draw_deck[0])

func bet_changed() -> void:
	if player_hands[1].is_active:
		bet_visual_managers_multiple_hands[0].update_bet(bet)
		bet_visual_managers_multiple_hands[1].update_bet(second_hand_bet)
		bet_visual_manager_single_hand.update_bet(0)
	else:
		bet_visual_managers_multiple_hands[0].update_bet(0)
		bet_visual_managers_multiple_hands[1].update_bet(0)
		bet_visual_manager_single_hand.update_bet(bet)
