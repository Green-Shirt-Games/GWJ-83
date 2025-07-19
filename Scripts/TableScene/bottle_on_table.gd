class_name BottleOnTable
extends TextureButton

@export var bottle_data : BottleData
signal bottle_pressed(BottleOnTable)

func _init(data : BottleData) -> void:
	bottle_data = data

func _ready() -> void:
	_update_visual()
	scale = Vector2(0.2, 0.2)

func _update_visual() -> void:
	_get_textures()

func _get_textures() -> void:
	get_placeholder_textures()
	#match bottle_data.type:
		#BottleData.TYPE.PEEK_DEALER:
			#pass
		#BottleData.TYPE.PEEK_SHOE:
			#pass
		#BottleData.TYPE.SWAP_DEALER:
			#pass
		#BottleData.TYPE.SPILL:
			#pass
		#BottleData.TYPE.SHOE_SWAP:
			#pass
		#BottleData.TYPE.ROTATE:
			#pass
		#BottleData.TYPE.DOUBLE:
			#pass
		#BottleData.TYPE.KEY:
			#pass

func get_placeholder_textures() -> void:
	texture_normal = load(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS.default.texture)
	texture_click_mask = get_bitmap_from_path(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS.default.mask)
	texture_pressed = load(Global.BOTTLE_ON_TABLE_TEXTURES_AND_MASKS.default.pressed)
	

func get_bitmap_from_path(path : String):
	var bitmap = BitMap.new()
	var image = (load(path) as Texture2D).get_image()
	bitmap.create_from_image_alpha(image)
	return bitmap

func _pressed() -> void:
	bottle_pressed.emit(self)
