extends Sprite2D
class_name DrinkHoverUI


@onready var drink_name_label : Label = $DrinkName
@onready var description_label : Label = $Description
@onready var price_label : Label = $Price

@export var fade_duration : float = 0.3

var tween : Tween = create_tween()

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()


func set_text(bottle_data : BottleData):
	drink_name_label.text = bottle_data.drink_name
	description_label.text = bottle_data.description
	price_label.text = str(bottle_data.price)


func fade_in() -> void:
	if tween.is_running():
		tween.kill()
	visible = true
	modulate.a = 0.0
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	await tween.finished


func fade_out() -> void:
	if tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await tween.finished
	visible = false
