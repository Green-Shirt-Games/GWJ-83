class_name BottleOnTable
extends TextureButton

@export var bottle_data : BottleData

func _get_data(data : BottleData) -> void:
	bottle_data = data
	_update_visual()

func _update_visual() -> void:
	# TODO get texture for stages and mask
	pass

func _on_pressed() -> void:
	if get_parent() is TableScene:
		(get_parent() as TableScene).bottle_pressed(bottle_data.type)
	else:
		push_error("Bottle on Table didnt find table as parent")
	queue_free()
