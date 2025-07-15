extends Node2D
class_name Register

signal buy_pressed(bottles : Array[Bottle], total_price : int)
signal too_poor()

@onready var buy_button : Button = $Button
@onready var price_label : Label = $ColorRect/Label
@onready var buy_area : Area2D = $BuyArea/Area2D
@export var bottle_parent : Bottle

var running_total : int = 0
var bottles : Array[Bottle] = []

func _ready() -> void:
	buy_button.pressed.connect(_on_buy_pressed)
	buy_area.body_entered.connect(_on_body_enter)
	buy_area.body_exited.connect(_on_body_exit)


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
	var padded_str := "%07d" % running_total
	padded_str = "$ " + padded_str
	price_label.text = padded_str


func clear():
	bottles = []
	running_total = 0
	_update_price_ui()
