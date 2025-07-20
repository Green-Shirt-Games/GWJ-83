class_name BottleOnTable
extends TextureButton

@export var bottle_data : BottleData
signal bottle_pressed(BottleOnTable)

var waiting_for_effect : bool = false

func _init(data : BottleData) -> void:
	bottle_data = data

func _ready() -> void:
	_update_visual()
	scale = Vector2(0.35, 0.35)

func _update_visual() -> void:
	_get_textures()

func _get_textures() -> void:
	var key : String = ""
	match bottle_data.type:
		BottleData.TYPE.PEEK_DEALER:
			key = "peek_deeler"
		BottleData.TYPE.PEEK_SHOE:
			key = "peek_shoe"
		BottleData.TYPE.SWAP_DEALER:
			key = "swap_dealer"
		BottleData.TYPE.SPILL:
			pass # Not implimented in time
		BottleData.TYPE.SHOE_SWAP:
			key = "shoe_swap"
		BottleData.TYPE.ROTATE:
			key = "rotate"
		BottleData.TYPE.DOUBLE:
			key = "double"
		_:
			get_placeholder_textures()
			push_error(bottle_data.type, " doesn't have texture assigned")
			return
	if key == "":
		get_placeholder_textures()
		push_error(bottle_data.type, " doesn't have texture assigned")
		return
	texture_normal = load(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS[key].texture)
	texture_click_mask = load(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS[key].mask)
	texture_hover = load(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS[key].pressed)

func get_placeholder_textures() -> void:
	texture_normal = load(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS.default.texture)
	texture_click_mask = load(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS.default.mask)
	texture_hover = load(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS.default.pressed)


func _pressed() -> void:
	bottle_pressed.emit(self)
