## Node that keeps track of children card score and their position within itself

class_name CardHand
extends Node2D

var bust : bool = false
var best_score : int = 0

func _ready() -> void:
	child_entered_tree.connect(_update_best_score)
	child_entered_tree.connect(_update_card_positions)

func reset() -> void:
	for child in get_children():
		child.queue_free()
	bust = false

func _update_card_positions(_child : Node):
	pass # TODO

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
