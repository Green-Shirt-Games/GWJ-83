extends RigidBody2D
class_name Bottle

@export var sway_strength := 0.015  # How much mouse delta affects rotation force
@export var angular_damping := 2.0  # Resistance to swinging
@export var swing_frequency := 4.0  # How fast the object oscillates when swinging
@export var max_angle := deg_to_rad(80)        # Limit how far it can rotate (in radians)
@export var max_angular_v := 2.0
@onready var mouse_area : Area2D = $Scale/Area2D
@onready var collision_stream_player : AudioStreamPlayer2D = $CollisionStream
@onready var pickup_stream_player : AudioStreamPlayer2D = $PickupStream

@export var bottle_resource : BottleData

var glow_sprite : Sprite2D
@onready var current_sprite : Sprite2D = $Scale/Sprite2D

var dragging := false
var mouse_offset := Vector2.ZERO
var _angular_velocity := 0.0
var swing_angle := 0.0
var previous_mouse_pos := Vector2.ZERO

func _ready():
	mouse_area.input_pickable = true
	mouse_area.input_event.connect(_on_area_input)
	mouse_area.mouse_entered.connect(_on_mouse_enter)
	mouse_area.mouse_exited.connect(_on_mouse_exit)
	create_glow_sprite()
	set_hover_ui()

func _on_area_input(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = true
		mouse_offset = global_position - event.position
		previous_mouse_pos = event.position
		get_viewport().set_input_as_handled()
		freeze = true
		linear_velocity = Vector2.ZERO
		set_children_scale(1)
		collision_layer = 1
		collision_mask = 1
		pickup_stream_player.play()

func _input(event):
	if dragging and event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = false
		rotation = 0
		linear_velocity = Vector2.ZERO
		_angular_velocity = 0.0
		swing_angle = 0.0
		freeze = false

func _process(delta):
	if !freeze:
		return
	
	var mouse_pos = get_global_mouse_position()
	var mouse_delta = mouse_pos - previous_mouse_pos
	previous_mouse_pos = mouse_pos
	
	if dragging:
		var target_pos : Vector2 = mouse_pos + mouse_offset
		global_position = lerp(global_position, target_pos, 0.1)
	
	if dragging && abs(mouse_delta.x) > 0.1:
		_angular_velocity += mouse_delta.x * sway_strength
	else:
		var restoring_force = -swing_angle * swing_frequency * swing_frequency
		var damping_force = -_angular_velocity * angular_damping
		var total_torque = restoring_force + damping_force
		_angular_velocity += total_torque * delta
	
	_angular_velocity = clamp(_angular_velocity, -max_angular_v, max_angular_v)

	swing_angle += _angular_velocity * delta
	swing_angle = clamp(swing_angle, -max_angle, max_angle)
	rotation = swing_angle

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

func set_children_scale(s : float) -> void:
	for child in get_children():
		child.scale = Vector2.ONE * s


var impact_threshold = Vector2(13, 75).length_squared() #This needs tweaking
@export var audio_cooldown_sec = 1.5
var on_cooldown = false
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if on_cooldown:
		return
	var contact_count = state.get_contact_count()
	for i in contact_count:
		var impulse = state.get_contact_impulse(i)
		if impulse.length_squared() > impact_threshold:
			var collider = state.get_contact_collider_object(i)
			if not collision_stream_player.playing:
				collision_stream_player.play()
				on_cooldown = true
				get_tree().create_timer(audio_cooldown_sec).timeout.connect(func():
					on_cooldown = false)

func set_hover_ui():
	if bottle_resource == null:
		return
	$Scale/HoverUI/DrinkName.text = bottle_resource.drink_name
	$Scale/HoverUI/Description.text = bottle_resource.description
	$Scale/HoverUI/Price.text = str(bottle_resource.price)
