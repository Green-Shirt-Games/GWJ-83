extends Control


@onready var bar := $Bar
@onready var table := $TableScene
@onready var door : Door = $Door
@onready var end_sprite : Sprite2D = $endTransition


var current_room : Global.ROOMS = Global.ROOMS.BAR

func _ready() -> void:
	Global.change_room.connect(_change_room)
	Global.player_exited_door.connect(on_door_opened)
	Global.final_hand_over.connect(end_final_hand)
	_change_room(Global.ROOMS.DOOR)
	Global.player_lost_all_chips.connect(func():end_final_hand(false))
	

func _change_room(to : Global.ROOMS) -> void:
	if to == current_room:
		push_error("Trying to change into same room")
		return
	match current_room:
		Global.ROOMS.BAR:
			bar.visible = false
			bar._reset()
			set_physics_process(false)
		Global.ROOMS.TABLE:
			table.visible = false
		Global.ROOMS.DOOR:
			door.visible = false
	match to:
		Global.ROOMS.BAR:
			bar.visible = true
			set_physics_process(true)
		Global.ROOMS.TABLE:
			table.visible = true
		Global.ROOMS.DOOR:
			door.visible = true
	current_room = to

var tween : Tween
func on_door_opened(count):
	if count == 1: start_final_encounter()
	if count == 2: show_win_splash()


func start_final_encounter():
	end_sprite.visible = true
	tween = create_tween()
	tween.tween_property(end_sprite, "scale", end_sprite_scale * 10, 4)
	await tween.finished
	_change_room(Global.ROOMS.TABLE)
	tween = create_tween()
	tween.tween_property(end_sprite, "scale", Vector2.ZERO, 4)
	await  tween.finished
	end_sprite.visible = false
	Global.final_hand_started.emit()

@onready var end_sprite_scale : Vector2 = $endTransition.scale

func show_win_splash():
	end_sprite.visible = true
	tween = create_tween()
	tween.tween_property(end_sprite, "scale", end_sprite_scale * 10, 4)
	await tween.finished
	$EndSplash.visible = true
	SfxAutoload.player_wins()
	get_tree().change_scene_to_file("res://Scenes/end_splash_screen.tscn")

func end_final_hand(won):
	if won: return
	
	end_sprite.visible = true
	tween = create_tween()
	tween.tween_property(end_sprite, "scale", end_sprite_scale * 10, 4)
	await tween.finished
	$EndSplash.visible = true
	get_tree().change_scene_to_file("res://Scenes/end_splash_screen.tscn")
