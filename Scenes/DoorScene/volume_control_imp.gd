extends Node2D

var glow_sprite : Sprite2D
@onready var current_sprite : Sprite2D = $ImpTail
@onready var tail_area : Area2D = $ImpTail/Area2D
@onready var tail_sprite : Sprite2D = $ImpTail
@onready var tail_rect : ColorRect = $TailRect
@onready var imp_body : Sprite2D = $VolumeImp
@export var max_length : float = 250
@export var value : float = 1
@export var tilt : float = 20
@export var tilt_delay : float = 1.0 
var timer : Timer

var dragging : bool = false
@onready var tail_delta : float = tail_sprite.position.y - tail_rect.position.y
@onready var tail_start : float = tail_sprite.position.y
@onready var starting_tail_len : float = tail_rect.size.y

@onready var eyes : Node2D = $VolumeImp/eyes

@onready var sample_stream : AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var bus_name : String = "Master"
@export var tick_interval : float = 0.1
var bus_default_db : float = 0.0


func _ready() -> void:
	create_glow_sprite()
	tail_area.mouse_entered.connect(_on_mouse_enter)
	tail_area.mouse_exited.connect(_on_mouse_exit)
	tail_area.input_event.connect(_input_event)
	
	tilt_delay = randf_range(0.3, 1)
	
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = tilt_delay
	timer.timeout.connect(_tilt)
	add_child(timer)
	timer.start()
	
	tail_sprite.position.y += max_length
	set_tail_pos(max_length)
	
	bus_default_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
	sample_stream.bus = bus_name
	
	


func _tilt():
	if imp_body.rotation < 0:
		imp_body.rotation = deg_to_rad(tilt)
	else:
		imp_body.rotation = deg_to_rad(-tilt)


func set_tail_pos(length_delta):
	if length_delta <= 0:
		tail_sprite.position.y = tail_start
		value = 0
		set_eyes_scale(1)
		return
	if length_delta > max_length:
		tail_sprite.position.y = tail_start + max_length
		value = 1
		set_eyes_scale(2)
		return
	
	value = clamp(length_delta/max_length,0,1)
	set_eyes_scale(1+value)
	tail_rect.size.y = starting_tail_len + length_delta

func _process(delta: float) -> void:
	if !dragging:
		return
	
	tail_sprite.global_position.y = get_global_mouse_position().y
	var length_delta = tail_sprite.position.y - tail_start
	set_tail_pos(length_delta)
	set_volume(value)


var old_vol : float = 1
func set_volume(value : float):
	value = clampf(value, 0 , 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), SfxAutoload.linear_to_db(value, bus_default_db))
	
	var vol_delta : float = abs(old_vol - value)
	if vol_delta > tick_interval:
		sample_stream.play()
		old_vol = value

func _input_event(viewport: Node, event: InputEvent, shape_idx: int):
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
	glow_sprite.texture = current_sprite.texture
	glow_sprite.modulate = Color(1, 1, 0, 0.5)
	glow_sprite.scale = Vector2.ONE * 1.2
	glow_sprite.position = Vector2.ZERO
	glow_sprite.show_behind_parent = true
	glow_sprite.name = "Highlight"
	glow_sprite.visible = false

	current_sprite.add_child(glow_sprite)


func set_eyes_scale(_scale):
	eyes.scale = Vector2.ONE * _scale
