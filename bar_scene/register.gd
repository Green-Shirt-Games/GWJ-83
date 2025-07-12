extends Node2D
class_name Register

signal buy_pressed(bottles : Array[Bottle], total_price : int)

@onready var buy_button : Button = $Button
@onready var price_label : Label = $ColorRect/Label
@onready var buy_area : Area2D = $BuyArea/Area2D

var running_total : int = 0
var bottles : Array[Bottle] = []

func _ready() -> void:
	buy_button.pressed.connect(_on_buy_pressed)
	buy_area.area_entered.connect(_on_area_enter)
	buy_area.area_exited.connect(_on_area_exit)


func _on_buy_pressed():
	buy_pressed.emit(bottles, running_total)


func _on_area_enter(area : Area2D):
	if !area.is_in_group("bottle"):
		return
	
	var bottle : Bottle = area.get_parent()
	
	if !bottles.has(bottle): 
		bottles.append(bottle)
		running_total += bottle.price
		_update_price_ui()


func _on_area_exit(area : Area2D):
	if !area.is_in_group("bottle"):
		return
	
	var bottle : Bottle = area.get_parent()
	if bottles.has(bottle): 
		bottles.erase(bottle)
		running_total -= bottle.price
		_update_price_ui()


func _update_price_ui():
	var padded_str := "%07d" % running_total
	padded_str = "$ " + padded_str
	price_label.text = padded_str


func clear():
	bottles = []
	running_total = 0
	_update_price_ui()
