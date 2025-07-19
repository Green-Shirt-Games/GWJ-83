extends Node2D

@export var gained_color : Color
@export var loss_color : Color
@export var hold_time : float = 1
@export var fade_time : float = 0.5
@onready var value_label : Label = $value
@onready var delta_label : Label = $delta
@onready var stream_player : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	Global.money_changed.connect(_on_money_change)
	_on_money_change(Global.money)
	delta_label.modulate.a = 0


func _on_money_change(old_value):
	var new_value = Global.money
	
	var delta = new_value - old_value
	
	if delta > 0:
		_on_money_gained(delta)
	if delta < 0:
		_on_money_lost(delta)
	
	value_label.text = str(new_value)

func _on_money_gained(gained_amount : int):
	delta_label.modulate = gained_color
	delta_label.text = "+" + str(gained_amount)
	stream_player.play()
	fade_in_and_out()


func _on_money_lost(lost_amount : int):
	delta_label.modulate = loss_color
	delta_label.text = "-" + str(abs(lost_amount))
	fade_in_and_out()

var tween : Tween = null
func fade_in_and_out():
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween()
	delta_label.modulate.a = 0
	tween.tween_property(delta_label, "modulate:a", 1.0, fade_time) 
	tween.tween_interval(hold_time)                            
	tween.tween_property(delta_label, "modulate:a", 0.0, fade_time) 
