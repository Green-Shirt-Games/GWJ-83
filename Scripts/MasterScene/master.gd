extends Control


@onready var bar := $Bar
@onready var table := $TableScene
@onready var door : Door = $Door
@onready var end_sprite : Sprite2D = $endTransition


var current_room : Global.ROOMS = Global.ROOMS.BAR

func _ready() -> void:
	Global.change_room.connect(_change_room)
	Global.player_exited_door.connect(on_door_opened)
	
	_change_room(Global.ROOMS.DOOR)
	

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
	if count > 1: show_win_splash()


func start_final_encounter():
	end_sprite.visible = true
	tween = create_tween()
	tween.tween_property(end_sprite, "scale", end_sprite.scale * 10, 4)
	await tween.finished
	_change_room(Global.ROOMS.TABLE)
	tween = create_tween()
	tween.tween_property(end_sprite, "scale", Vector2.ZERO, 4)
	await  tween.finished
	end_sprite.visible = false
	Global


func show_win_splash():
	pass


func show_you_lose_splash():
	pass
