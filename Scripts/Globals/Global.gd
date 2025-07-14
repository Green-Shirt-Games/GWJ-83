extends Node

enum ROOMS{BAR, TABLE, DOOR}
@warning_ignore("unused_signal")
signal change_room(to : ROOMS)
enum CARD_SUITS{CLUB, DIAMOND , HEART, SPADE}
enum CARD_VALUES{VA, V2, V3, V4, V5, V6, V7, V8, V9, V10, VJ, VQ, VK}
enum GAME_STATES { BETTING, DEALING, PLAYER_TURN, DEALER_TURN, RESULT, RESET} 

const SUBSCENE_PATHS : Dictionary[String, String] = {
	"card_visual" : "res://Scenes/SubScenes/card_visual.tscn" ,
}

const POINTS_LIMIT = 21

# Player's data
var money = 10000 :
	set(value):
		money = value
		money_changed.emit()
signal money_changed

# Cards shared data
const CARD_TEXTURE_SIZE : Vector2 = Vector2(298, 433)
const CARD_FRONT_ATLAS : Texture2D = preload("res://Assets/Cards_N0_Faces_CLN.png")
