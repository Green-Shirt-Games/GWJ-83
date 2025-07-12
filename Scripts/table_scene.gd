extends Control



# temp code, to be moved to separate GamaManager, to keep data about table between scene changes

var current_state : GAME_STATES 
var draw_deck : Array[CardData] = []
var discard_deck : Array[CardData] = []
signal state_changed



func _ready() -> void:
	_prepare_deck()
	_change_state(GAME_STATES.BETTING)

func _change_state(new_state : GAME_STATES) -> void:
	current_state = new_state
	state_changed.emit()
	match current_state:
		GAME_STATES.BETTING:
			pass
			# enable bet buttons
			# disable card action buttons
			# wait for player to confirm bet
		GAME_STATES.DEALING:
			# enable 
			# disable all player's actions
			# draw cards for player and dealer
			# wait for animations to finish
			pass
		GAME_STATES.PLAYER_TURN:
			# enable action buttons
			# disable card bet buttons
			# wait for player to stand, bust or double_down
			pass
		GAME_STATES.DEALER_TURN:
			# enable
			# disable all player's actions
			# dealer reveals hole_card, draws 'till value of cards is 17+
			# wait for dealers' bust or stand
			pass
		GAME_STATES.RESULT:
			# disable all player's actions
			# check for dealer's bust, if not - check who's value is bigger
			# add/remove/keep player's bet acording to results
			# wait for animation to finish
			pass
		GAME_STATES.RESET:
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
