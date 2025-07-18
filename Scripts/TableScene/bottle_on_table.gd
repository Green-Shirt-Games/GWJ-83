class_name BottleOnTable
extends TextureButton

@export var bottle_data : BottleData

func _init(data : BottleData) -> void:
	bottle_data = data

func _ready() -> void:
	_update_visual()

func _update_visual() -> void:
	# TODO get texture for stages and mask
	if bottle_data == null:
		visible = false
		return
	
	_get_textures()

func _get_textures() -> void:
	match bottle_data.type:
		BottleData.TYPE.PEEK_DEALER:
			pass
		BottleData.TYPE.PEEK_SHOE:
			pass
		BottleData.TYPE.SWAP_DEALER:
			pass
		BottleData.TYPE.SPILL:
			pass
		BottleData.TYPE.SHOE_SWAP:
			pass
		BottleData.TYPE.ROTATE:
			pass
		BottleData.TYPE.DOUBLE:
			pass
		BottleData.TYPE.KEY:
			pass

func get_placeholder_textures() -> void:
	pass

func _on_pressed() -> void:
	if get_parent() is TableScene:
		(get_parent() as TableScene).bottle_pressed(bottle_data.type)
	else:
		push_error("Bottle on Table didnt find table as parent")
	queue_free()
