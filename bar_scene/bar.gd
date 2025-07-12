extends Node2D
class_name Bar

@onready var spawn_points : Array[Node] = $BottleSpawnPoints.get_children()
@onready var bottles : Array[Node] = $Bottles.get_children()
@export var drink_poof_scene : PackedScene
@onready var register : Register = $Register

func _ready() -> void:
	_reset()
	register.buy_pressed.connect(_on_buy_pressed)


func _reset():
	var shuffled_points = spawn_points.duplicate()
	shuffled_points.shuffle()
	
	var i = 0
	for bottle in bottles:
		bottle.global_position = shuffled_points[i].global_position
		i += 1

func _on_buy_pressed(bottles : Array[Bottle], total_price : int):
	
	#TODO
	
	register.clear()
	
	for bottle in bottles:
		bottle.queue_free() #TODO
		var drink_poof = drink_poof_scene.instantiate()
		drink_poof.global_position = bottle.global_position
		add_child(drink_poof)
