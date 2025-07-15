extends Sprite2D
class_name DrinkHoverUI


@onready var drink_name_label : Label = $DrinkName
@onready var description_label : Label = $Description
@onready var price_label : Label = $Price

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()


func set_text(bottle_data : BottleData):
	drink_name_label.text = bottle_data.drink_name
	description_label.text = bottle_data.description
	price_label.text = str(bottle_data.price)
