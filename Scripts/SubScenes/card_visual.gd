class_name CardVisual
extends Node2D

@export var face_up : bool = false
@export var card_data : CardData
@export_group("Internal connections")
@export var front_sprite : Sprite2D
@export var back_sprite : Sprite2D
@export var temp_card_info : Label

func update_visual() -> void:
	front_sprite.visible = face_up
	back_sprite.visible = !face_up
	temp_card_info.text = card_data.get_card_name().replace(" ", "\n")
