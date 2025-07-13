class_name CardHand
extends HBoxContainer

var bust : bool = false
var best_score : int = 0 :
	set(value):
		print("new best score: " , value)
		best_score = value

func _ready() -> void:
	child_entered_tree.connect(_update_best_score)

func reset() -> void:
	for child in get_children():
		child.queue_free()
	bust = false

func _update_best_score(_child : Node):
	print("Child entered, calcualating new best score")
	var possible_scores : Array[int] = [0]
	for card in get_children():
		if card is CardVisual:
			var new_possible_scores : Array[int] = []
			for value in card.card_data.get_card_values():
				for score in possible_scores:
					new_possible_scores.append(value + score)
			possible_scores = new_possible_scores
	
	var to_bust : bool = false
	for score in possible_scores:
		if score < Global.POINTS_LIMIT:
			to_bust = true
			break
	if to_bust:
		bust = true
		best_score = possible_scores.min()
	else:
		var max_score := 0
		for score in possible_scores:
			if score > max_score and score <= Global.POINTS_LIMIT:
				max_score = score
		best_score = max_score
