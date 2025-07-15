class_name CardData
extends Resource

var value : Global.CARD_VALUES
var suit : Global.CARD_SUITS
#var card_modifiers[CardModifier] : Array

func _init(init_value : Global.CARD_VALUES, init_suit : Global.CARD_SUITS) -> void:
	value = init_value
	suit = init_suit
	

func get_card_values() -> Array[int]:
	var card_values : Array[int] = _get_initial_card_values()
	#for modifier in card_modifiers:
		# put modifiers here
	return card_values

func _get_initial_card_values() -> Array[int]:
	match value:
		Global.CARD_VALUES.VA: return [1,11]
		Global.CARD_VALUES.V2: return [2]
		Global.CARD_VALUES.V3: return [3]
		Global.CARD_VALUES.V4: return [4]
		Global.CARD_VALUES.V5: return [5]
		Global.CARD_VALUES.V6: return [6]
		Global.CARD_VALUES.V7: return [7]
		Global.CARD_VALUES.V8: return [8]
		Global.CARD_VALUES.V9: return [9]
		Global.CARD_VALUES.V10 , \
		Global.CARD_VALUES.VJ , Global.CARD_VALUES.VQ,Global.CARD_VALUES.VK:
			return [10]
		_:
			push_error("Unexpected card value:" , value, )
			return []

func get_card_name() -> String:
	var prefix : String
	var suffix : String
	match suit:
		Global.CARD_SUITS.SPADE:
			suffix = "spades"
		Global.CARD_SUITS.HEART:
			suffix = "hearts"
		Global.CARD_SUITS.DIAMOND:
			suffix = "diamonds"
		Global.CARD_SUITS.CLUB:
			suffix = "clubs"
	match value:
		Global.CARD_VALUES.VA: 
			prefix = "Ace"
		Global.CARD_VALUES.V2:
			prefix = "Two"
		Global.CARD_VALUES.V3: 
			prefix = "Three"
		Global.CARD_VALUES.V4:
			prefix = "Four"
		Global.CARD_VALUES.V5: 
			prefix = "Five"
		Global.CARD_VALUES.V6:
			prefix = "Six"
		Global.CARD_VALUES.V7:
			prefix = "Seven"
		Global.CARD_VALUES.V8:
			prefix = "Eight"
		Global.CARD_VALUES.V9:
			prefix = "Nine"
		Global.CARD_VALUES.V10:
			prefix = "Ten" 
		Global.CARD_VALUES.VJ:
			prefix = "Jack"
		Global.CARD_VALUES.VQ:
			prefix = "Quuen"
		Global.CARD_VALUES.VK:
			prefix = "King"
	return prefix + " of " + suffix
