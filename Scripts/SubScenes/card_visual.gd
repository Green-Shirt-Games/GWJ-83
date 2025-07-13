class_name CardVisual
extends TextureRect

@export var face_up : bool = false
@export var card_data : CardData

@export var front_sprite : Texture2D
@export var back_sprite : Texture2D
@export_group("Internal connections")
@export var temp_card_info : Label

func _ready() -> void:
	update_visual()

func get_data(card : CardData, _face_up : bool = true) -> void:
	card_data = card
	face_up = _face_up

func update_visual() -> void:
	if face_up:
		texture = front_sprite
	else:
		texture = back_sprite
	temp_card_info.text = card_data.get_card_name().replace(" ", "\n")
	temp_card_info.visible = face_up

func reveal() -> void:
	face_up = true
	update_visual()
