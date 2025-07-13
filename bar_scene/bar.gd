extends Node2D
class_name Bar

signal to_table_pressed

@onready var top_shelf_spawn_points : Array[Node] = $TopShelfSpawnPoints.get_children()
@onready var bottom_shelf_spawn_points : Array[Node] = $BottomShelfSpawnPoints.get_children()
@onready var bottles : Array[Node] = $Bottles.get_children()
@export var drink_poof_scene : PackedScene
@onready var register : Register = $Register
@onready var to_table_button : Button = $ToTableButton

var top_shelf_layer = 2
var bottom_shelf_layer = 4
var foreground_layer = 1
var top_shelf_scale = 0.5
var bottom_shelf_scale = 0.7

func _ready() -> void:
	_reset()
	register.buy_pressed.connect(_on_buy_pressed)
	to_table_button.pressed.connect(
		func():
			to_table_pressed.emit()
	)


func _reset():
	#Split bottles into two desired groups
	bottles.shuffle()
	var mid = bottles.size() / 2
	var for_top_shelf = bottles.slice(0, mid)
	var for_bottom_shelf = bottles.slice(mid)
	
	add_bottles_to_shelf(for_top_shelf, top_shelf_spawn_points, top_shelf_layer, top_shelf_scale)
	add_bottles_to_shelf(for_bottom_shelf, bottom_shelf_spawn_points, bottom_shelf_layer, bottom_shelf_scale)


func add_bottles_to_shelf(bottles, spawn_points : Array[Node], layer : int, bottle_scale : float):
	var shuffled_points = spawn_points.duplicate()
	shuffled_points.shuffle()
	
	var i = 0
	for bottle in bottles:
		bottle.global_position = shuffled_points[i].global_position
		bottle.collision_layer = layer
		bottle.collision_mask = layer
		bottle.set_children_scale(bottle_scale)
		i += 1

func _on_buy_pressed(bottles : Array[Bottle], total_price : int):
	
	#TODO
	
	register.clear()
	
	for bottle in bottles:
		bottle.queue_free() #TODO
		var drink_poof = drink_poof_scene.instantiate()
		drink_poof.global_position = bottle.global_position
		add_child(drink_poof)
