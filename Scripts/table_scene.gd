extends Control

@export_group("Internal connections")
@export var player_hands : HBoxContainer
@export var dealer_hand : CardHand
@export var bet_buttons_container : Control
@export var play_buttons_container : Control
@export var split_button : Button
@export var double_down_button : Button
@export var player_money_label : Label

# temp code, to be moved to separate GamaManager, to keep data about table between scene changes
var active_player_hand : int = 0
var current_state : Global.GAME_STATES 
var draw_deck : Array[CardData] = []
var discard_deck : Array[CardData] = []
var bet : int = 0 
signal state_changed

func _ready() -> void:
	_game_start()
	_change_state(Global.GAME_STATES.BETTING)
	Global.money_changed.connect(_update_money_label)
	_update_money_label()


func _change_state(new_state : Global.GAME_STATES) -> void:
	current_state = new_state
	state_changed.emit()
	match current_state:
		Global.GAME_STATES.BETTING:
			pass
			# enable bet buttons
			bet_buttons_container.visible = true
			# disable card action buttons
			play_buttons_container.visible = false
			# wait for player to confirm bet
		Global.GAME_STATES.DEALING:
			# enable 
			# disable all player's actions
			bet_buttons_container.visible = false
			play_buttons_container.visible = false
			# draw cards for player and dealer
			for i in 2:
				_add_card_to_player_hand()
			_add_card_to_dealer_hand(true)
			_add_card_to_dealer_hand(false) # second drawn card is face down
			# wait for animations to finish
			_change_state(Global.GAME_STATES.PLAYER_TURN)
		Global.GAME_STATES.PLAYER_TURN:
			# enable action buttons
			play_buttons_container.visible = true
			# disable card bet buttons
			bet_buttons_container.visible = false
			split_button.visible = _check_if_split_possible()
				
			# wait for player to stand, bust or double_down
			pass
		Global.GAME_STATES.DEALER_TURN:
			# enable
			# disable all player's actions
			for hand in player_hands.get_children():
				print("Player's cards in " , hand.name, " : ", _list_all_cards_in_hand(hand))
			split_button.visible = false
			play_buttons_container.visible = false
			bet_buttons_container.visible = false
			# dealer reveals hole_card, draws 'till value of cards is 17+
			(dealer_hand.get_child(1) as CardVisual).reveal()
			await get_tree().create_timer(2).timeout
			while dealer_hand.best_score < 17:
				await get_tree().create_timer(2).timeout
				_add_card_to_dealer_hand(true)
			print("Dealer's cards:" , _list_all_cards_in_hand(dealer_hand))
			_change_state(Global.GAME_STATES.RESULT)
		Global.GAME_STATES.RESULT:
			# disable all player's actions
			play_buttons_container.visible = false
			bet_buttons_container.visible = false
			for hand in player_hands.get_children():
				# check for dealer's bust, if not - check who's value is bigger
				# add/remove/keep player's bet acording to results
				if dealer_hand.bust:
					print("Player won: dealer is busted with ", dealer_hand.best_score)
					_player_won()
				else:
					if hand is CardHand:
						if hand.bust:
							print("Player lost: ", hand.best_score, " is bust")
							_player_lost()
						else:
							if hand.best_score > dealer_hand.best_score:
								print("Player won: " , hand.best_score , " > " , dealer_hand.best_score)
								_player_won(hand.best_score == Global.POINTS_LIMIT)
							elif hand.best_score < dealer_hand.best_score:
								print("Player lost: " , hand.best_score , " < " , dealer_hand.best_score)
								_player_lost()
							else:
								print("Player tied: " , hand.best_score , " = " , dealer_hand.best_score)
								_player_tied()
					else:
						push_error("Unexpected node in player's hands folder")
			await get_tree().create_timer(2).timeout
			_change_state(Global.GAME_STATES.RESET)
		Global.GAME_STATES.RESET:
			pass
			# disable all player's actions
			play_buttons_container.visible = false
			bet_buttons_container.visible = false
			# put all played cards in discard deck
			for card in dealer_hand.get_children():
				discard_deck.append((card as CardVisual).card_data)
			dealer_hand.reset()
			for hand in player_hands.get_children():
				for card in hand.get_children():
					discard_deck.append((card as CardVisual).card_data)
				(hand as CardHand).reset()
			if player_hands.get_child_count() > 1:
				player_hands.remove_child(player_hands.get_child(1))
			# reset deck, if cards left is less than 15 (overkill?)
			if draw_deck.size() < 15:
				_reset_deck()
			# wait for animation to finish
			await get_tree().create_timer(2).timeout
			_change_state(Global.GAME_STATES.BETTING)

func _check_if_split_possible() -> bool:
	return (player_hands.get_child(0).get_child(0) as CardVisual).card_data.value == \
			(player_hands.get_child(0).get_child(1) as CardVisual).card_data.value

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
func _add_card_to_player_hand() -> void:
	var hand : CardHand = player_hands.get_child(active_player_hand)
	hand.add_child(_draw_card())
	if hand.bust:
		if active_player_hand >= player_hands.get_child_count() - 1:
			_change_state(Global.GAME_STATES.RESULT)
		else:
			active_player_hand += 1

func _add_card_to_dealer_hand(face_up : bool) -> void:
	var new_card : CardVisual = _draw_card()
	new_card.face_up = face_up
	dealer_hand.add_child(new_card)
	new_card.update_visual()

func _draw_card() -> CardVisual:
	var card : CardVisual = (load(Global.SUBSCENE_PATHS.card_visual) as PackedScene).instantiate()
	card.get_data(draw_deck.pop_front())
	return card
#endregion


func _list_all_cards_in_hand(hand : CardHand) -> String:
	var list : String = ""
	for card in hand.get_children():
		if list.length() > 0:
			list += ", "
		list += (card as CardVisual).card_data.get_card_name()
	return list

func _player_won(is_blackjack : bool = false) -> void:
	Global.money += bet * 2
	print("Player won ", bet * 2)

func _player_lost() -> void:
	pass

func _player_tied() -> void:
	Global.money += bet

func _on_draw_cards_button_pressed() -> void:
	_change_state(Global.GAME_STATES.DEALING)

func _on_temp_place_100_bet_pressed() -> void:
	bet = 100
	Global.money -= bet
	_change_state(Global.GAME_STATES.DEALING)

func _update_money_label() -> void:
	player_money_label.text = "money: " + str(Global.money)

func _on_hit_button_pressed() -> void:
	_add_card_to_player_hand()

func _on_split_button_pressed() -> void:
	player_hands.add_child(CardHand.new())
	player_hands.get_child(0).get_child(1).reparent(
		player_hands.get_child(1)
	)
	active_player_hand = 1
	_add_card_to_player_hand()
	active_player_hand = 0
	_add_card_to_player_hand()

func _on_stand_button_pressed() -> void:
	if player_hands.get_child_count() > active_player_hand + 1:
		active_player_hand += 1
	else:
		_change_state(Global.GAME_STATES.DEALER_TURN)

func _on_double_down_button_pressed() -> void:
	Global.money -= bet
	bet *= 2
	_add_card_to_player_hand()
	await get_tree().create_timer(2)
	_change_state(Global.GAME_STATES.DEALER_TURN)
