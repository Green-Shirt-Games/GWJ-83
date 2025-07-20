class_name BetManager
extends Control

@export var starting_min_bet : int = 10
@export var bet_increase_per_round : float = 1.2
@export var max_bet_multiplier : int = 10
@export var table : TableScene
@export var visual_bet_manager_one_hand : BetVisualManager
@export_group("Internal connections")
@export var confirm_bet : ButtonWithSFX
@export var min_bet_button : ButtonWithSFX
@export var lower_bet_button : ButtonWithSFX
@export var increase_bet_button : ButtonWithSFX
@export var max_bet_button : ButtonWithSFX

var min_bet : int = 0
var current_bet_multiplier : int = 1
var current_max_bet_multiplier : int = 10

var current_bet : int = 0

func _prepare_for_bets():
	if visible:
		min_bet = roundi(starting_min_bet * (1 + (0.2 * (table.hands_played))))
		if Global.money > min_bet:
			@warning_ignore("integer_division")
			current_max_bet_multiplier = clampi(Global.money / min_bet, 1, 10)
			current_bet_multiplier = clampi(current_bet_multiplier, 1 , current_max_bet_multiplier)
		else: # all in
			min_bet = Global.money
			current_max_bet_multiplier = 1
			current_bet_multiplier = 1
		_update_bet()

func _ready() -> void:
	self.visibility_changed.connect(_prepare_for_bets)

func _update_bet() -> void:
	current_bet = min_bet * current_bet_multiplier
	visual_bet_manager_one_hand.update_bet(current_bet)
	_update_buttons()

func _update_buttons() -> void:
	if current_bet_multiplier > 1:
		min_bet_button.visible = true
		lower_bet_button.visible = true
	else:
		min_bet_button.visible = false
		lower_bet_button.visible = false
	if current_bet_multiplier < current_max_bet_multiplier:
		increase_bet_button.visible = true
		max_bet_button.visible = true
	else:
		increase_bet_button.visible = false
		max_bet_button.visible = false
	confirm_bet.text = str(current_bet)


func final_hand_bet() -> void:
	current_bet = Global.money
	_on_bet_button_pressed()

func _on_bet_button_pressed() -> void:
	Global.money -= current_bet
	table.bet = current_bet
	table._change_state(Global.GAME_STATES.DEALING)


func _on_increase_bet_button_pressed() -> void:
	if current_bet_multiplier < current_max_bet_multiplier:
		current_bet_multiplier += 1
	SfxAutoload.place_chips()
	_update_bet()


func _on_decrease_bet_button_pressed() -> void:
	if current_bet_multiplier > 1:
		current_bet_multiplier -= 1
	SfxAutoload.place_chips()
	_update_bet()


func _on_max_bet_button_pressed() -> void:
	current_bet_multiplier = current_max_bet_multiplier
	SfxAutoload.place_chips()
	_update_bet()


func _on_min_bet_button_pressed() -> void:
	current_bet_multiplier = 1
	SfxAutoload.place_chips()
	_update_bet()
