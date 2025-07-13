extends Control

@export_group("Internal connections")
@export var player_hands : HBoxContainer
@export var dealer_hand : CardHand
@export var bet_buttons_container : Control
@export var play_buttons_container : Control
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
			# wait for player to stand, bust or double_down
			pass
		Global.GAME_STATES.DEALER_TURN:
			# enable
			# disable all player's actions
			# dealer reveals hole_card, draws 'till value of cards is 17+
			# wait for dealers' bust or stand
			pass
		Global.GAME_STATES.RESULT:
			# disable all player's actions
			# check for dealer's bust, if not - check who's value is bigger
			# add/remove/keep player's bet acording to results
			# wait for animation to finish
			pass
		Global.GAME_STATES.RESET:
			pass
			# disable all player's actions
			# put all played cards in discard deck
			# reset deck, if cards left is less than 15 (overkill?)
			# wait for animation to finish

func _game_start() -> void:
	_prepare_deck()
	_reset_deck()

func _reset_deck() -> void:
	draw_deck.append_array(discard_deck)
	discard_deck.clear()
	draw_deck.shuffle()

func _prepare_deck() -> void:
	for suit in Global.CARD_SUITS.size():
		for value in Global.CARD_VALUES.size():
			draw_deck.append(
				CardData.new(
					value as Global.CARD_VALUES,
					suit as Global.CARD_SUITS
					)
				)

#region CardDraw
func _add_card_to_player_hand() -> void:
	print(player_hands.get_child(active_player_hand))
	player_hands.get_child(active_player_hand).add_child(_draw_card())

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

func _get_best_score(in_container : CardHand) -> int:
	return in_container._get_best_score()

func _player_lost() -> void:
	pass


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


func _on_stand_button_pressed() -> void:
	if player_hands.get_child_count() > active_player_hand + 1:
		active_player_hand += 1
	else:
		print("Done")
