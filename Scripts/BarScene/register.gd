extends Node2D
class_name Register

signal buy_pressed(bottles : Array[Bottle], total_price : int)
signal too_poor()
signal too_many()

@onready var buy_button : Button = $Button
@onready var buy_area : Area2D = $BuyArea/Area2D
@onready var values_parent : Node2D = $Values
@onready var value_tick_stream : AudioStreamPlayer2D = $ValueTicks
@onready var kaching_stream : AudioStreamPlayer2D = $KachingPlayer
@export var bottle_parent : Bottle

var running_total : int = 0
var current_total_str : String = "000000000"
var bottles : Array[Bottle] = []

var value_labels : Array[Label] = []

func _ready() -> void:
	buy_button.pressed.connect(_on_buy_pressed)
	buy_area.body_entered.connect(_on_body_enter)
	buy_area.body_exited.connect(_on_body_exit)
	
	for child in values_parent.get_children():
		value_labels.append(child)


func _on_buy_pressed():
	if Global.money < running_total:
		too_poor.emit()
		return
	
	if !Global.table_can_fit_bottles(bottles.size()):
		too_many.emit()
		return
	
	kaching_stream.play()
	Global.money -= running_total
	for bottle in bottles:
		if bottle.bottle_resource.type == BottleData.TYPE.KEY:
			Global.key_purchased.emit()
		else:
			Global.add_bottle_to_table(bottle.bottle_resource)
	
	buy_pressed.emit(bottles, running_total)


func _on_body_enter(body):
	if body is not Bottle:
		return
	
	var bottle : Bottle = body
	
	if !bottles.has(bottle): 
		bottles.append(bottle)
		running_total += bottle.bottle_resource.price
		_update_price_ui()


func _on_body_exit(body):
	if body is not Bottle:
		return
	
	var bottle : Bottle = body
	if bottles.has(bottle): 
		bottles.erase(bottle)
		running_total -= bottle.bottle_resource.price
		_update_price_ui()

var padded_str : String
func _update_price_ui():
	padded_str = "%09d" % running_total
	
	var shuffled_indexes : Array = range(padded_str.length())
	shuffled_indexes.shuffle()
	for i in shuffled_indexes:
		if padded_str[i] != current_total_str[i]:
			_update_value_index(i, padded_str[i])
	
	current_total_str = padded_str


func _update_value_index(index : int, new_value : String):
	var label : Label = value_labels[index]
	
	await get_tree().create_timer(randf_range(0.1, 0.4)).timeout
	
	label.text = ""
	value_tick_stream.play()
	
	await get_tree().create_timer(0.05).timeout
	
	label.text = new_value
	value_tick_stream.play()


func clear():
	bottles = []
	running_total = 0
	_update_price_ui()
