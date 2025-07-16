class_name TableScene
extends Control

@export_group("Internal connections")
@export_subgroup("Position markers")
@export var shoe : Marker2D
@export var discard: Marker2D
@export_subgroup("UI elements")
@export var player_hands : Node2D
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

var default_card_fly_time : float = 0.3
var skip_dealing : bool = false

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
			if skip_dealing:
				skip_dealing = false
			else:
				# enable 
				# disable all player's actions
				bet_buttons_container.visible = false
				play_buttons_container.visible = false
				
				# draw cards for player and dealer
				while (player_hands.get_child(0) as CardHand).get_cards_amount() < 2:
					await _add_card_to_player_hand()
				while dealer_hand.get_cards_amount() < 2:
					await _add_card_to_dealer_hand(dealer_hand.get_cards_amount() < 1)
			
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
			split_button.visible = false
			play_buttons_container.visible = false
			bet_buttons_container.visible = false
			# dealer reveals hole_card, draws 'till value of cards is 17+
			await (dealer_hand.get_child(1) as CardVisual).reveal()
			while dealer_hand.best_score < 17:
				await _add_card_to_dealer_hand(true)
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
			await get_tree().create_timer(2).timeout #TODO move this await to voiceline trigger
			_change_state(Global.GAME_STATES.RESET)
		Global.GAME_STATES.RESET:
			pass
			# disable all player's actions
			play_buttons_container.visible = false
			bet_buttons_container.visible = false
			# put all played cards in discard deck
			for card in dealer_hand.get_children():
				if !(card as CardVisual).is_frozen:
					discard_deck.append((card as CardVisual).card_data)
			dealer_hand.reset()
			for hand in player_hands.get_children():
				for card in hand.get_children():
					if !(card as CardVisual).is_frozen:
						discard_deck.append((card as CardVisual).card_data)
				(hand as CardHand).reset()
			if player_hands.get_child_count() > 1:
				for card in player_hands.get_child(1).get_children():
					# Move frozen cards to first player hand
					move_card_to_hand(card, player_hands.get_child(0), -1 , false)
				player_hands.remove_child(player_hands.get_child(1))
			# reset deck, if cards left is less than 15 (overkill?)
			if draw_deck.size() < 15:
				_reset_deck()
			# wait for animation to finish
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
func _add_card_to_player_hand():
	var hand : CardHand = player_hands.get_child(active_player_hand)
	await move_card_to_hand(_draw_card(), hand)
	if hand.bust:
		if active_player_hand >= player_hands.get_child_count() - 1:
			_change_state(Global.GAME_STATES.RESULT)
		else:
			active_player_hand += 1

func _add_card_to_dealer_hand(face_up : bool) -> void:
	var new_card : CardVisual = _draw_card()
	new_card.face_up = face_up
	await move_card_to_hand(new_card, dealer_hand)
	new_card.update_visual()

func _draw_card() -> CardVisual:
	var card : CardVisual = (load(Global.SUBSCENE_PATHS.card_visual) as PackedScene).instantiate()
	card.get_data(draw_deck.pop_front())
	print(draw_deck.size())
	add_child(card)
	if card.card_data == null:
		push_error("No data provided to card at draw")
	card.position = shoe.position
	return card
#endregion

func move_card_to_hand(card_to_move : CardVisual, to_hand : CardHand, 
hand_position : int = -1, with_animation : bool = true):
	# hand position might be useful, but can't figure out proper way to impliment TODO
	var new_hand_position : int
	if hand_position < 0:
		new_hand_position = to_hand.get_child_count()
	else:
		new_hand_position = hand_position
	if with_animation:
		await animation_card_fly(card_to_move, get_visual_position_for_card(to_hand, new_hand_position))
	card_to_move.reparent(to_hand)

func move_card_to_shoe(card_to_move : CardVisual, with_animation : bool = true):
	if with_animation:
		await animation_card_fly(card_to_move, shoe.position)
	draw_deck.insert(0, card_to_move.card_data)
	card_to_move.queue_free()

func move_card_to_discard(card_to_move : CardVisual, with_animation : bool = false):
	if with_animation:
		await animation_card_fly(card_to_move, discard.position)
	discard_deck.append(card_to_move.card_data)
	card_to_move.queue_free()

func get_visual_position_for_card(in_hand : CardHand, at_hand_position : int) -> Vector2:
	# TODO
	return $Marker2D.position

func animation_card_fly(card : CardVisual, to_position : Vector2, time_to_fly : float = default_card_fly_time):
	var tween := get_tree().create_tween()
	tween.tween_property(card, "position", to_position, time_to_fly)
	await tween.finished

#region Game results

func _player_won(is_blackjack : bool = false) -> void:
	if is_blackjack:
		Global.money += bet * 3
		print("Player won with blackjack " ,  bet * 3)
	else:
		Global.money += bet * 2
		print("Player won ", bet * 2)

func _player_lost() -> void:
	pass

func _player_tied() -> void:
	Global.money += bet
#endregion

#region UI buttons
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
	if _double_bet():
		await _add_card_to_player_hand()
		_change_state(Global.GAME_STATES.DEALER_TURN)
	else:
		Global.not_enough_money.emit()

#endregion

func _double_bet() -> bool:
	if Global.money >= bet:
		Global.money -= bet
		bet *= 2
		return true
	else:
		return false

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
			pass # TODO determine how to display data
		BottleData.TYPE.SWAP:
			pass
			# pick random card in both active hands
			if player_hands.get_child(active_player_hand).get_cards_amount() > 0 and dealer_hand.get_cards_amount() > 0:
				var player_hand_to_pick_card_from = player_hands.get_child(active_player_hand)
				var player_card_to_swap : CardVisual = player_hand_to_pick_card_from.get_children().pick_random()
				var dealer_card_to_swap : CardVisual = dealer_hand.get_children().pick_random()
				move_card_to_hand(player_card_to_swap, dealer_hand)
				await move_card_to_hand(dealer_card_to_swap, player_hand_to_pick_card_from)
			else:
				return false
		BottleData.TYPE.SPILL:
			pass # TODO
		BottleData.TYPE.SHOE_SWAP:
			if player_hands.get_child(active_player_hand).get_child_count() > 0:
				_add_card_to_player_hand()
				await move_card_to_shoe(player_hands.get_child(active_player_hand).get_children().pick_random())
			else:
				return false
		BottleData.TYPE.ROTATE:
			pass
		BottleData.TYPE.SNEAK_BET:
			skip_dealing = true
			_change_state(Global.GAME_STATES.BETTING)
		BottleData.TYPE.DOUBLE:
			if !_double_bet():
				return false
		_:
			push_error("Unexpected bottle type triggered")
			return false
	return true
	


func _on_button_pressed() -> void:
	print("Cards in player's hand:")
	for card in player_hands.get_child(active_player_hand).get_children():
		print((card as CardVisual).card_data.get_card_name())
	print("Cards in dealer's hand:")
	for card in dealer_hand.get_children():
		print((card as CardVisual).card_data.get_card_name())
	await bottle_pressed(BottleData.TYPE.SWAP)
	print("SWAP HAPPENED")
	print("Cards in player's hand:")
	for card in player_hands.get_child(active_player_hand).get_children():
		print((card as CardVisual).card_data.get_card_name())
	print("Cards in dealer's hand:")
	for card in dealer_hand.get_children():
		print((card as CardVisual).card_data.get_card_name())
