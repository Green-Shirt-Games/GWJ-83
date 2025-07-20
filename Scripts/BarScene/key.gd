extends Bottle
class_name Key

signal key_touched_early

var money_pickup_threshold : int = 10000

func _ready() -> void:
	super._ready()
	money_pickup_threshold = bottle_resource.price
	freeze = true

func _on_area_input(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Global.money >= money_pickup_threshold:
			super._on_area_input(viewport, event, shape_idx)
		else:
			key_touched_early.emit()
