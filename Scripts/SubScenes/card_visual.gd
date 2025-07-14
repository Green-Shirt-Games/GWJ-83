class_name CardVisual
extends TextureRect

@export var face_up : bool = false
@export var card_data : CardData

@export var back_sprite : Texture2D

func _ready() -> void:
	update_visual()

func get_data(card : CardData, _face_up : bool = true) -> void:
	card_data = card
	face_up = _face_up

func update_visual() -> void:
	if face_up:
		select_atlas_area()
	else:
		texture = back_sprite

func select_atlas_area() -> void:
	var texture_region := AtlasTexture.new()
	texture_region.atlas = Global.CARD_FRONT_ATLAS
	
	var atlas_x = (card_data.value as int) * Global.CARD_TEXTURE_SIZE.x
	var atlas_y = (card_data.suit as int) * Global.CARD_TEXTURE_SIZE.y
	
	texture_region.region = Rect2(
		Vector2(atlas_x, atlas_y),
		Global.CARD_TEXTURE_SIZE)
	
	texture = texture_region

func reveal() -> void:
	print("Card getting revealed")
	face_up = true
	update_visual()
