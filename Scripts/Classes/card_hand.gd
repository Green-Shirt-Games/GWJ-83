## Node that keeps track of children card score and their position within itself

class_name CardHand
extends Node2D

var bust : bool = false
var best_score : int = 0

## hand-specific modifiers
@export var table_size_x : float = 3456.0
@export var offset_direction : int = 1
var default_y_position : float
var default_x_position : float = 0.0
var between_cards_space_percent = 0.1
var card_fly_time : float = 0.5 # TODO move to global

func _ready() -> void:
	child_entered_tree.connect(_update_best_score)
	child_entered_tree.connect(_update_card_positions)

func reset() -> void:
	for child in get_children():
		if (child as CardVisual).is_frozen:
			(child as CardVisual).is_frozen = false
		else:
			child.queue_free()
	bust = false

func get_cards_amount() -> int:
	return get_child_count()

func pre_parenting_card_position_adjustment(card : CardVisual) -> void:
	CardVisual.position -= self.position

func _update_card_positions(_child : Node):
	var offset : float = 0.0
	for card in get_children():
		if card is CardVisual:
			get_card_to_position( card , Vector2(
				table_size_x / 2 + offset,0
			))
			offset += offset_direction * Global.CARD_TEXTURE_SIZE.x * (1 + between_cards_space_percent)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", 
			((-1 * offset_direction * (get_child_count() - 1) * Global.CARD_TEXTURE_SIZE.x * (1 + between_cards_space_percent)) / 2) + default_x_position ,
			card_fly_time)
	await tween.finished

func get_card_to_position(card : CardVisual, to_position : Vector2):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(card, "position", to_position, card_fly_time)

func get_card_position(at_index : int) -> Vector2:
	if !at_index < get_child_count():
		push_error("Trying to get position of card that's not present")
		return Vector2.INF
	return get_child(at_index).position

func list_all_cards() -> String: # Debug function
	var list : String = ""
	for card in get_children():
		if list.length() > 0:
			list += ", "
		list += (card as CardVisual).card_data.get_card_name()
	return list

func _update_best_score(_child : Node):
	var possible_scores : Array[int] = [0]
	for card in get_children():
		if card is CardVisual:
			var new_possible_scores : Array[int] = []
			for value in card.card_data.get_card_values():
				for score in possible_scores:
					new_possible_scores.append(value + score)
			possible_scores = new_possible_scores
	
	var to_bust : bool = true
	for score in possible_scores:
		if score <= Global.POINTS_LIMIT:
			to_bust = false
			break
	if to_bust:
		bust = true
		print(name , " is busted: ", possible_scores.min())
		best_score = possible_scores.min()
	else:
		var max_score := 0
		for score in possible_scores:
			if score > max_score and score <= Global.POINTS_LIMIT:
				max_score = score
		best_score = max_score
