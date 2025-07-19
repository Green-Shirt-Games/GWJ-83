extends Node

signal key_purchased
signal welcome_line_finished
var bar_entered_yet : bool = false
enum ROOMS{BAR, TABLE, DOOR}
@warning_ignore("unused_signal")
signal change_room(to : ROOMS)
enum CARD_SUITS{CLUB, DIAMOND , HEART, SPADE}
enum CARD_VALUES{VA, V2, V3, V4, V5, V6, V7, V8, V9, V10, VJ, VQ, VK}
enum GAME_STATES { BETTING, DEALING, PLAYER_TURN, DEALER_TURN, RESULT, RESET, INTRO} 

const SUBSCENE_PATHS : Dictionary[String, String] = {
	"card_visual" : "res://Scenes/SubScenes/card_visual.tscn" ,
}

const POINTS_LIMIT = 21

# Player's data
var money = 1000 :
	set(value):
		var old_value = money
		money = value
		money_changed.emit(old_value)
signal money_changed(old_value)

var money_delta_since_bar : int = 0

# Cards shared data
const CARD_TEXTURE_SIZE : Vector2 = Vector2(303.5, 439.0)
const CARD_FRONT_ATLAS : Texture2D = preload("res://Assets/BlackJack_Cards_Front.png")
const CARD_BACK_TEXTURE : Texture2D = preload("res://Assets/BlackJack_Cards_Back.png")

# Bottles shared data
const BOTTLE_ON_TABLE_TEXTURES_AND_MASKS : Dictionary[String, Dictionary] = {
	"default" : {
		"texture" : "res://Assets/Bottles/default_bottle.png" ,
		"mask" : "res://Assets/Bottles/default_bottle.png",
		"pressed" : "res://Assets/Bottles/default_bottle_pressed.png" ,
	}
}

var table : TableScene

func table_can_fit_bottles(amount : int) -> bool:
	return table.bottles_manager.check_for_room_for_bottle(amount)

func add_bottle_to_table(bottle_data : BottleData) -> void:
	table.bottles_manager.add_bottle(bottle_data)

var bottle_type_to_res : Dictionary[BottleData.TYPE, BottleData] = {}

func _ready() -> void:
	change_room.connect(_on_room_change)

func _on_room_change(to : ROOMS):
	match to:
		ROOMS.BAR:
			SfxAutoload.fade_down_melody()
		ROOMS.DOOR:
			SfxAutoload.fade_down_melody()
		ROOMS.TABLE:
			SfxAutoload.fade_up_melody()
