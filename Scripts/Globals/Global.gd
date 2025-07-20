extends Node

signal key_purchased
signal welcome_line_finished
signal player_exited_door(count : int)
signal final_hand_started
var bar_entered_yet : bool = false
enum ROOMS{BAR, TABLE, DOOR}
@warning_ignore("unused_signal")
signal change_room(to : ROOMS)
enum CARD_SUITS{CLUB, DIAMOND , HEART, SPADE}
enum CARD_VALUES{VA, V2, V3, V4, V5, V6, V7, V8, V9, V10, VJ, VQ, VK}
enum GAME_STATES { BETTING, DEALING, HOLE_CARD , PLAYER_TURN, DEALER_TURN, RESULT, RESET, INTRO} 

const SUBSCENE_PATHS : Dictionary[String, String] = {
	"card_visual" : "res://Scenes/SubScenes/card_visual.tscn" ,
}

const POINTS_LIMIT = 21

# Player's data
var money = 10000 :
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
	} ,
	"peek_deeler" : {
		"texture" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Deviled-eye-Gin.png" ,
		"mask" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Deviled-eye-Gin_mask.png" ,
		"pressed" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Deviled-eye-Gin_highlight.png" ,
	} ,
	"peek_shoe" : {
		"texture" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Show-Ray.png" ,
		"mask" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Show-Ray_mask.png" ,
		"pressed" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Show-Ray_highlight.png" ,
	} ,
	"swap_dealer" : {
		"texture" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Swap-a-Pop.png" ,
		"mask" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Swap-a-Pop_mask.png" ,
		"pressed" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Swap-a-Pop_highlight.png" ,
	} ,
	"shoe_swap" : {
		"texture" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Counter-Court-Cocktail.png" ,
		"mask" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Counter-Court-Cocktail_mask.png" ,
		"pressed" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Counter-Court-Cocktail_highlight.png" ,
	},
	"rotate" : {
		"texture" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Rotation-Randy.png" ,
		"mask" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Rotation-Randy_mask.png",
		"pressed" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Rotation-Randy_highlight.png"
	} ,
	"double" : {
		"texture" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Double_Up-Dirty.png" ,
		"mask" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Double_Up-Dirty_mask.png" ,
		"pressed" : "res://Assets/Bottles/Black_Jack_Table_Bottles_Double_Up-Dirty_highlight.png"
	}
}

var table : TableScene
var hole_rule_active : bool = true

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
