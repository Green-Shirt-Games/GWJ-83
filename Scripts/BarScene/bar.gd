extends Node2D
class_name Bar

@onready var bottles : Array[Node] = $Bottles.get_children()
@export var drink_poof_scene : PackedScene
@onready var register : Register = $Register
@onready var hover_ui : DrinkHoverUI = $HoverUI
@onready var key : Key = $Key

func _ready() -> void:
	_reset()
	_bind_bottle_ui()
	register.buy_pressed.connect(_on_buy_pressed)


func _reset():
	for bottle : Bottle in bottles:
		bottle.reset()
		bottle.collision_layer = 2
		bottle.collision_mask = 2
		bottle.z_index = 0


func on_bar_entered():
	var last_seen_money_delta : int = Global.money_delta_since_bar
	pass #TODO trigger voice lines based on 


func add_bottles_to_shelf(_bottles, spawn_points : Array[Node], layer : int, bottle_scale : float):
	var shuffled_points = spawn_points.duplicate()
	shuffled_points.shuffle()
	
	var i = 0
	for bottle in _bottles:
		bottle.global_position = shuffled_points[i].global_position
		bottle.collision_layer = layer
		bottle.collision_mask = layer
		bottle.freeze = true
		bottle.scale = Vector2.ONE * bottle_scale
		i += 1

func _on_buy_pressed(bottles : Array[Bottle], total_price : int):
	
	#TODO
	
	register.clear()
	
	for bottle in bottles:
		bottle.queue_free() #TODO
		var drink_poof = drink_poof_scene.instantiate()
		drink_poof.global_position = bottle.global_position
		add_child(drink_poof)

func _bind_bottle_ui():
	key.mouse_entered_bottle.connect(_on_bottle_mouse_enter)
	key.mouse_exited_bottle.connect(_on_bottle_mouse_exit)
	for bottle : Bottle in bottles:
		bottle.mouse_entered_bottle.connect(_on_bottle_mouse_enter)
		bottle.mouse_exited_bottle.connect(_on_bottle_mouse_exit)


var hovered_bottles : Array[Bottle] = []
var bottle_of_interest : Bottle = null

func _on_bottle_mouse_enter(bottle : Bottle):
	
	if hovered_bottles.has(bottle):
		return
	else:
		hovered_bottles.append(bottle)
	
	bottle_of_interest = bottle
	hover_ui.set_text(bottle.bottle_resource)
	await hover_ui.fade_in()


func _on_bottle_mouse_exit(bottle : Bottle):	
	if hovered_bottles.has(bottle):
		hovered_bottles.erase(bottle)
	
	if hovered_bottles.size() > 0:
		hover_ui.set_text(hovered_bottles[0].bottle_resource)
	else:
		await hover_ui.fade_out()
