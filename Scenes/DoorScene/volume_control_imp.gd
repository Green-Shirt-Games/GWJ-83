extends Node2D


@onready var imp_sprite : Sprite2D = $Sprite2D
@onready var sample_stream : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var starting_y = global_position.y 
@onready var hover_area : Area2D = $Sprite2D/Area2D

@export var max_movement : float = 250
@export var value : float = 1
@export var tick_interval : float = 0.05

var dragging : bool = false
var glow_sprite : Sprite2D
var bus_default_db : float = 0.0



@export var bus_name : String = "Master"



func _ready() -> void:
	create_glow_sprite()
	hover_area.mouse_entered.connect(_on_mouse_enter)
	hover_area.mouse_exited.connect(_on_mouse_exit)
	hover_area.input_event.connect(_input_event)
	
	bus_default_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
	sample_stream.bus = bus_name
	value = 1

func _process(_delta: float) -> void:
	if !dragging:
		return
	
	var old_y = global_position.y
	var y_delta = starting_y - get_global_mouse_position().y
	y_delta = clampf(y_delta, 0, max_movement)
	global_position.y = starting_y + y_delta
	var new_vol = remap(y_delta, 0, max_movement, 0, 1)
	value = new_vol
	set_volume(value)


var old_vol : float = 1
func set_volume(_value : float):
	_value = clampf(_value, 0 , 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), SfxAutoload.linear_to_db(_value, bus_default_db))
	
	var vol_delta : float = abs(old_vol - _value)
	if vol_delta > tick_interval:
		sample_stream.play()
		old_vol = _value

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = true

func _input(event):
	if dragging and event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = false

func _on_mouse_enter():
	glow_sprite.visible = true

func _on_mouse_exit():
	glow_sprite.visible = false

func create_glow_sprite():
	glow_sprite = Sprite2D.new()
	glow_sprite.texture = imp_sprite.texture
	glow_sprite.modulate = Color(1, 1, 0, 0.5)
	glow_sprite.scale = Vector2.ONE * 1.2
	glow_sprite.position = Vector2.ZERO
	glow_sprite.show_behind_parent = true
	glow_sprite.name = "Highlight"
	glow_sprite.visible = false

	imp_sprite.add_child(glow_sprite)
