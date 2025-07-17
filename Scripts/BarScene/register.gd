extends Node2D
class_name Register

signal buy_pressed(bottles : Array[Bottle], total_price : int)
signal too_poor()

@onready var buy_button : Button = $Button
@onready var buy_area : Area2D = $BuyArea/Area2D
@onready var values_parent : Node2D = $Values
@onready var audio_stream : AudioStreamPlayer2D = $AudioStreamPlayer2D
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
	else:
		Global.money -= running_total
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


func _update_price_ui():
	var padded_str := "%09d" % running_total
	
	var index : int = 0
	for i in range(padded_str.length()):
		if padded_str[i] != current_total_str[i]:
			await get_tree().create_timer(0.1).timeout
			_update_value_index(i, padded_str[i])
	
	current_total_str = padded_str


func _update_value_index(index : int, new_value : String):
	var label : Label = value_labels[index]
	label.text = new_value
	audio_stream.play()


func clear():
	bottles = []
	running_total = 0
	_update_price_ui()
