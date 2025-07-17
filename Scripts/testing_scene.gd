extends Node2D

func _ready() -> void:
	$CardVisual.get_data(CardData.new(Global.CARD_VALUES.VA, Global.CARD_SUITS.DIAMOND))


func _on_button_pressed() -> void:
	($CardVisual as CardVisual).flip(!$CardVisual.face_up)
