class_name CardVisual
extends Sprite2D

@export var face_up : bool = false
@export var card_data : CardData

var is_frozen : bool = false
const DEFAULT_FLIP_TIME : float = 0.3



func get_data(card : CardData, _face_up : bool = true) -> void:
	card_data = card
	face_up = _face_up
	update_visual()

func update_visual() -> void:
	if card_data == null:
		push_error("No data was provided to card: ", self)
		return
	
	if face_up:
		select_atlas_area()
	else:
		texture = Global.CARD_BACK_TEXTURE

func select_atlas_area() -> void:
	var texture_region := AtlasTexture.new()
	texture_region.atlas = Global.CARD_FRONT_ATLAS
	
	var atlas_x = (card_data.value as int) * \
			(Global.CARD_TEXTURE_SIZE.x)
	var atlas_y = (card_data.suit as int) *  \
			(Global.CARD_TEXTURE_SIZE.y)
	
	texture_region.region = Rect2(
		Vector2(atlas_x, atlas_y),
		Global.CARD_TEXTURE_SIZE)
	
	texture = texture_region

func flip(to_face_up : bool):
	if to_face_up == face_up:
		return
	
	var tween_1 := get_tree().create_tween()
	await tween_1.tween_property(self, "scale", Vector2(0.01, 1), DEFAULT_FLIP_TIME).finished
	face_up = to_face_up
	update_visual()
	var tween_2 := get_tree().create_tween()
	await tween_2.tween_property(self, "scale", Vector2(1,1), DEFAULT_FLIP_TIME).finished

func reveal():
	await flip(true)
